require 'open3'

built_in_klasses = [
  BasicObject,
  Object,
  # ARGF.class,
  Array,
  Binding,
  # ConditionVariable,
  # Data,
  Dir,
  Encoding,
  Encoding::Converter,
  Enumerator,
  Enumerator::Lazy,
  FalseClass,
  Fiber,
  File::Stat,
  Hash,
  IO,
  File,
  MatchData,
  Method,
  Module,
  Class,
  # Mutex,
  NilClass,
  Numeric,
  Complex,
  Float,
  Integer,
  Bignum,
  Fixnum,
  Rational,
  ObjectSpace::WeakMap,
  Proc,
  Process::Status,
  # Queue,
  Random,
  Range,
  Regexp,
  RubyVM,
  RubyVM::InstructionSequence,
  # SizedQueue,
  String,
  Struct,
  Struct::Tms,
  Symbol,
  Thread,
  Thread::Backtrace::Location,
  Thread::ConditionVariable,
  Thread::Mutex,
  Thread::Queue,
  Thread::SizedQueue,
  ThreadGroup,
  Time,
  TracePoint,
  TrueClass,
  UnboundMethod
]

built_in_klasses.each do |klass|
  $stderr.puts klass
  klass.instance_methods(false).each do |method|
    m = klass.instance_method(method)
    o, s = Open3.capture2e('refe', "#{m.owner}##{method}")

    unless s.success? && !o.include?('no such method')
      puts "#{m.owner}##{method}"
    end
  end
end
