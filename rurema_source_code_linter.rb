require 'bitclust'

class RuremaSourceCodeLinter
  def initialize
    umap = BitClust::URLMapper.new({})
    @compiler = BitClust::RDCompiler.new(umap, 1, force: true)
    @codes = []
    def_list
    def_emlist
    stub_method_signature
  end

  def lint(rd_path, version: '2.4.0', &block)
    src = BitClust::Preprocessor.read(rd_path, 'version' => version)
    @codes.clear
    @compiler.compile(src)
    @codes.reject! {|c| desc?(c) }
    @codes.select!(&block)
    @codes
  end

  private

  def def_list
    codes = @codes

    @compiler.define_singleton_method(:list) do
      lines = unindent_block(canonicalize(@f.break(/\A\S/)))
      while lines.last.empty?
        lines.pop
      end
      out = StringIO.new
      lines.each do |line|
        out.puts line
      end
      codes << out.string
    end
  end

  def def_emlist
    codes = @codes
    @compiler.define_singleton_method(:emlist) do
      @f.gets   # discard "//emlist{"
      out = StringIO.new
      @f.until_terminator(%r<\A//\}>) do |line|
        out.puts line.rstrip
      end
      codes << out.string
    end
  end

  def stub_method_signature
    @compiler.define_singleton_method(:method_signature) do |_sig_line, _first|
      # stub
    end
  end

  def desc?(s)
    s.include?('[[m:') ||
      s.include?('[[c:') ||
      s.include?('[[ref:') ||
	    s.bytesize.to_f / s.size > 2
  end
end
