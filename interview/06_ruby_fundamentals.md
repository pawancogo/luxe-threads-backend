# Ruby Fundamentals Guide

## Table of Contents
1. [Ruby Basics](#ruby-basics)
2. [Data Types & Variables](#data-types--variables)
3. [Control Structures](#control-structures)
4. [Methods & Blocks](#methods--blocks)
5. [Classes & Objects](#classes--objects)
6. [Modules & Mixins](#modules--mixins)
7. [Error Handling](#error-handling)
8. [Collections & Iteration](#collections--iteration)
9. [String Manipulation](#string-manipulation)
10. [File I/O & System Operations](#file-io--system-operations)
11. [Metaprogramming](#metaprogramming)
12. [Common Interview Questions](#common-interview-questions)

## Ruby Basics

### Ruby Philosophy
- **Everything is an object**: Even numbers and strings are objects
- **Dynamic typing**: No need to declare variable types
- **Interpreted language**: Code is executed line by line
- **Garbage collected**: Automatic memory management
- **Duck typing**: "If it walks like a duck and quacks like a duck, it's a duck"

### Ruby Syntax
```ruby
# Comments
# Single line comment

=begin
Multi-line comment
This is a block comment
=end

# Variables (snake_case)
user_name = "John"
user_age = 25
is_active = true

# Constants (UPPER_CASE)
MAX_USERS = 1000
API_BASE_URL = "https://api.example.com"

# Method names (snake_case)
def calculate_total
  # method body
end

# Class names (PascalCase)
class UserController
  # class body
end
```

## Data Types & Variables

### Basic Data Types
```ruby
# Numbers
integer = 42
float = 3.14
big_number = 1_000_000  # Underscores for readability

# Strings
single_quote = 'Hello World'
double_quote = "Hello World"
interpolation = "Hello #{user_name}"  # String interpolation
heredoc = <<~HEREDOC
  This is a multi-line string
  It preserves formatting
  HEREDOC

# Booleans
true_value = true
false_value = false
nil_value = nil  # Ruby's null

# Symbols (immutable strings)
user_status = :active
user_status = :inactive

# Arrays
numbers = [1, 2, 3, 4, 5]
mixed_array = [1, "hello", :symbol, true]
empty_array = []

# Hashes
user = {
  name: "John",
  age: 25,
  active: true
}

# Hash with string keys
user_string_keys = {
  "name" => "John",
  "age" => 25,
  "active" => true
}

# Hash with symbol keys (older syntax)
user_symbol_keys = {
  :name => "John",
  :age => 25,
  :active => true
}
```

### Variable Types
```ruby
# Local variables (lowercase or underscore)
local_var = "I'm local"

# Instance variables (start with @)
@instance_var = "I belong to an instance"

# Class variables (start with @@)
@@class_var = "I belong to the class"

# Global variables (start with $)
$global_var = "I'm global"

# Constants (start with uppercase)
CONSTANT_VAR = "I'm a constant"
```

### Type Checking & Conversion
```ruby
# Type checking
"hello".class          # => String
42.class              # => Integer
true.class            # => TrueClass
nil.class             # => NilClass

# Type conversion
"42".to_i             # => 42
42.to_s               # => "42"
"true".to_bool        # => true (custom method)
nil.to_s              # => ""

# Type checking methods
"hello".is_a?(String) # => true
42.is_a?(Numeric)     # => true
nil.nil?              # => true
"".empty?             # => true
```

## Control Structures

### Conditional Statements
```ruby
# if/elsif/else
age = 25

if age >= 18
  puts "Adult"
elsif age >= 13
  puts "Teenager"
else
  puts "Child"
end

# unless (opposite of if)
unless age < 18
  puts "Can vote"
end

# Ternary operator
status = age >= 18 ? "adult" : "minor"

# Case statement
grade = "B"

case grade
when "A"
  puts "Excellent"
when "B"
  puts "Good"
when "C"
  puts "Average"
else
  puts "Needs improvement"
end

# Case with ranges
score = 85

case score
when 90..100
  puts "A"
when 80..89
  puts "B"
when 70..79
  puts "C"
else
  puts "F"
end
```

### Loops
```ruby
# while loop
count = 0
while count < 5
  puts count
  count += 1
end

# until loop (opposite of while)
count = 0
until count >= 5
  puts count
  count += 1
end

# for loop
for i in 1..5
  puts i
end

# each (preferred in Ruby)
(1..5).each do |i|
  puts i
end

# times
5.times do |i|
  puts i
end

# upto/downto
1.upto(5) { |i| puts i }
5.downto(1) { |i| puts i }

# break and next
(1..10).each do |i|
  next if i.even?  # Skip even numbers
  break if i > 7   # Stop if i > 7
  puts i
end
```

## Methods & Blocks

### Method Definition
```ruby
# Basic method
def greet(name)
  "Hello, #{name}!"
end

# Method with default parameters
def greet(name = "World")
  "Hello, #{name}!"
end

# Method with keyword arguments
def create_user(name:, email:, age: 18)
  { name: name, email: email, age: age }
end

# Method with splat operator
def sum(*numbers)
  numbers.reduce(0, :+)
end

# Method with block
def with_logging
  puts "Starting operation"
  yield if block_given?
  puts "Operation completed"
end

# Method with explicit block parameter
def process_items(&block)
  items = [1, 2, 3, 4, 5]
  items.each(&block)
end
```

### Method Calls
```ruby
# Parentheses are optional
greet("John")
greet "John"

# Method chaining
"hello world".upcase.reverse  # => "DLROW OLLEH"

# Safe navigation operator (Ruby 2.3+)
user&.name&.upcase

# Method aliasing
alias_method :old_method, :new_method
```

### Blocks, Procs, and Lambdas
```ruby
# Blocks (anonymous functions)
[1, 2, 3].each { |x| puts x * 2 }

# Multi-line blocks
[1, 2, 3].each do |x|
  puts x * 2
  puts "---"
end

# Proc (stored block)
my_proc = Proc.new { |x| x * 2 }
[1, 2, 3].map(&my_proc)  # => [2, 4, 6]

# Lambda (strict Proc)
my_lambda = lambda { |x| x * 2 }
[1, 2, 3].map(&my_lambda)  # => [2, 4, 6]

# Differences between Proc and Lambda
proc = Proc.new { |x, y| puts x, y }
lambda_proc = lambda { |x, y| puts x, y }

proc.call(1)        # Works (y becomes nil)
lambda_proc.call(1) # Raises ArgumentError

# Block to Proc conversion
def my_method(&block)
  block.call("Hello")
end

my_method { |msg| puts msg }
```

### Yield and Block Given
```ruby
def my_method
  if block_given?
    yield("Hello from method")
  else
    puts "No block provided"
  end
end

my_method { |msg| puts msg }
my_method

# Yield with parameters
def calculate(a, b)
  result = a + b
  yield(result) if block_given?
  result
end

calculate(5, 3) { |result| puts "Result: #{result}" }
```

## Classes & Objects

### Class Definition
```ruby
class Person
  # Class variable
  @@total_people = 0
  
  # Class method
  def self.total_people
    @@total_people
  end
  
  # Constructor
  def initialize(name, age)
    @name = name
    @age = age
    @@total_people += 1
  end
  
  # Instance methods
  def name
    @name
  end
  
  def age
    @age
  end
  
  def name=(new_name)
    @name = new_name
  end
  
  def introduce
    "Hi, I'm #{@name} and I'm #{@age} years old"
  end
  
  # Private methods
  private
  
  def validate_age
    @age > 0
  end
  
  # Protected methods
  protected
  
  def can_access_private_info?
    @age >= 18
  end
end

# Usage
person = Person.new("John", 25)
puts person.introduce
puts Person.total_people
```

### Accessors
```ruby
class User
  # attr_reader (getter only)
  attr_reader :id, :created_at
  
  # attr_writer (setter only)
  attr_writer :password
  
  # attr_accessor (getter and setter)
  attr_accessor :name, :email
  
  def initialize(name, email)
    @id = generate_id
    @name = name
    @email = email
    @created_at = Time.now
  end
  
  private
  
  def generate_id
    SecureRandom.uuid
  end
end
```

### Inheritance
```ruby
class Animal
  attr_accessor :name, :age
  
  def initialize(name, age)
    @name = name
    @age = age
  end
  
  def speak
    "Some generic animal sound"
  end
  
  def move
    "Moving around"
  end
end

class Dog < Animal
  def initialize(name, age, breed)
    super(name, age)  # Call parent constructor
    @breed = breed
  end
  
  def speak
    "Woof!"
  end
  
  def fetch
    "Fetching the ball"
  end
end

class Cat < Animal
  def speak
    "Meow!"
  end
  
  def climb
    "Climbing the tree"
  end
end

# Usage
dog = Dog.new("Buddy", 3, "Golden Retriever")
puts dog.speak  # => "Woof!"
puts dog.move   # => "Moving around" (inherited)
```

### Method Overriding and Super
```ruby
class Parent
  def greet
    "Hello from parent"
  end
end

class Child < Parent
  def greet
    super + " and hello from child"
  end
end

child = Child.new
puts child.greet  # => "Hello from parent and hello from child"
```

## Modules & Mixins

### Module Definition
```ruby
module Loggable
  def log(message)
    puts "[#{Time.now}] #{message}"
  end
  
  def log_error(error)
    log("ERROR: #{error.message}")
  end
end

module Validatable
  def valid?
    errors.empty?
  end
  
  def errors
    @errors ||= []
  end
  
  def add_error(message)
    errors << message
  end
end

# Using modules as mixins
class User
  include Loggable
  include Validatable
  
  attr_accessor :name, :email
  
  def initialize(name, email)
    @name = name
    @email = email
  end
  
  def save
    if valid?
      log("Saving user: #{@name}")
      # Save logic here
      true
    else
      log_error("Validation failed")
      false
    end
  end
  
  def validate
    add_error("Name is required") if @name.nil? || @name.empty?
    add_error("Email is required") if @email.nil? || @email.empty?
    add_error("Invalid email format") unless @email&.include?("@")
  end
end
```

### Module Methods
```ruby
module MathUtils
  # Module method (called on module)
  def self.calculate_average(numbers)
    numbers.sum.to_f / numbers.length
  end
  
  # Instance method (mixed into classes)
  def square(number)
    number * number
  end
end

# Using module methods
average = MathUtils.calculate_average([1, 2, 3, 4, 5])

class Calculator
  include MathUtils
  
  def calculate_square(number)
    square(number)
  end
end
```

### Namespace Modules
```ruby
module Api
  module V1
    class UsersController
      def index
        "API V1 Users"
      end
    end
  end
  
  module V2
    class UsersController
      def index
        "API V2 Users"
      end
    end
  end
end

# Usage
Api::V1::UsersController.new.index  # => "API V1 Users"
Api::V2::UsersController.new.index  # => "API V2 Users"
```

## Error Handling

### Exception Handling
```ruby
# Basic exception handling
begin
  result = 10 / 0
rescue ZeroDivisionError => e
  puts "Error: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
ensure
  puts "This always runs"
end

# Rescue modifier
result = 10 / 0 rescue "Error occurred"

# Multiple rescue clauses
begin
  # Some code
rescue ArgumentError, TypeError => e
  puts "Argument or type error: #{e.message}"
rescue StandardError => e
  puts "Other error: #{e.message}"
end

# Custom exceptions
class ValidationError < StandardError
  attr_reader :field, :value
  
  def initialize(field, value, message = "Validation failed")
    @field = field
    @value = value
    super("#{message} for #{field}: #{value}")
  end
end

# Raising exceptions
def validate_age(age)
  raise ValidationError.new(:age, age, "Age must be positive") if age < 0
  raise ValidationError.new(:age, age, "Age must be less than 150") if age > 150
  true
end

# Using custom exceptions
begin
  validate_age(-5)
rescue ValidationError => e
  puts "Validation failed: #{e.message}"
  puts "Field: #{e.field}, Value: #{e.value}"
end
```

### Retry Logic
```ruby
def fetch_data_with_retry(max_attempts = 3)
  attempts = 0
  
  begin
    attempts += 1
    # Simulate API call
    raise "Network error" if rand < 0.7
    "Data fetched successfully"
  rescue StandardError => e
    if attempts < max_attempts
      puts "Attempt #{attempts} failed: #{e.message}. Retrying..."
      sleep(2 ** attempts)  # Exponential backoff
      retry
    else
      puts "All #{max_attempts} attempts failed"
      raise
    end
  end
end
```

## Collections & Iteration

### Arrays
```ruby
# Array creation
numbers = [1, 2, 3, 4, 5]
empty_array = []
array_with_default = Array.new(5, 0)  # [0, 0, 0, 0, 0]

# Array methods
numbers.length          # => 5
numbers.size            # => 5
numbers.empty?          # => false
numbers.include?(3)     # => true
numbers.index(3)        # => 2

# Adding elements
numbers << 6            # => [1, 2, 3, 4, 5, 6]
numbers.push(7)         # => [1, 2, 3, 4, 5, 6, 7]
numbers.unshift(0)      # => [0, 1, 2, 3, 4, 5, 6, 7]

# Removing elements
numbers.pop             # => 7, numbers = [0, 1, 2, 3, 4, 5, 6]
numbers.shift           # => 0, numbers = [1, 2, 3, 4, 5, 6]
numbers.delete(3)       # => 3, numbers = [1, 2, 4, 5, 6]

# Array iteration
numbers.each { |n| puts n }
numbers.each_with_index { |n, i| puts "#{i}: #{n}" }
numbers.map { |n| n * 2 }        # => [2, 4, 8, 10, 12]
numbers.select { |n| n.even? }   # => [2, 4, 6]
numbers.reject { |n| n.even? }   # => [1, 5]
numbers.find { |n| n > 3 }       # => 4
numbers.all? { |n| n > 0 }       # => true
numbers.any? { |n| n > 5 }       # => true

# Array manipulation
numbers.sort                    # => [1, 2, 4, 5, 6]
numbers.reverse                 # => [6, 5, 4, 2, 1]
numbers.uniq                    # => [1, 2, 4, 5, 6]
numbers.compact                 # => [1, 2, 4, 5, 6] (removes nils)
numbers.flatten                 # => [1, 2, 4, 5, 6] (flattens nested arrays)
```

### Hashes
```ruby
# Hash creation
user = { name: "John", age: 25, active: true }
empty_hash = {}
hash_with_default = Hash.new(0)  # Default value is 0

# Hash methods
user.keys           # => [:name, :age, :active]
user.values         # => ["John", 25, true]
user.length         # => 3
user.empty?         # => false
user.key?(:name)    # => true
user.value?("John") # => true

# Accessing values
user[:name]         # => "John"
user["name"]        # => nil (different key type)
user.fetch(:name)   # => "John"
user.fetch(:phone, "N/A")  # => "N/A" (default value)

# Modifying hashes
user[:email] = "john@example.com"
user.delete(:age)
user.merge!({ city: "New York" })

# Hash iteration
user.each { |key, value| puts "#{key}: #{value}" }
user.each_key { |key| puts key }
user.each_value { |value| puts value }
user.map { |k, v| "#{k}: #{v}" }
user.select { |k, v| v.is_a?(String) }
user.transform_values { |v| v.to_s }

# Hash manipulation
user.invert         # => {"John" => :name, 25 => :age, true => :active}
user.merge({ phone: "123-456-7890" })
```

### Ranges
```ruby
# Range creation
(1..10)     # Inclusive range: 1, 2, 3, ..., 10
(1...10)    # Exclusive range: 1, 2, 3, ..., 9
('a'..'z')  # Character range

# Range methods
(1..10).to_a        # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
(1..10).include?(5) # => true
(1..10).min         # => 1
(1..10).max         # => 10
(1..10).size        # => 10

# Range iteration
(1..5).each { |n| puts n }
(1..5).step(2) { |n| puts n }  # => 1, 3, 5
```

## String Manipulation

### String Methods
```ruby
# String creation
single_quote = 'Hello World'
double_quote = "Hello World"
interpolation = "Hello #{name}"
heredoc = <<~HEREDOC
  This is a multi-line string
  It preserves formatting
  HEREDOC

# String methods
"hello".length           # => 5
"hello".size             # => 5
"hello".empty?           # => false
"hello".upcase           # => "HELLO"
"HELLO".downcase         # => "hello"
"hello world".capitalize # => "Hello world"
"hello world".titleize   # => "Hello World" (Rails method)

# String manipulation
"hello".reverse          # => "olleh"
"hello world".split      # => ["hello", "world"]
"hello world".split("")  # => ["h", "e", "l", "l", "o", " ", "w", "o", "r", "l", "d"]
["hello", "world"].join(" ")  # => "hello world"

# String searching
"hello world".include?("world")  # => true
"hello world".start_with?("hello")  # => true
"hello world".end_with?("world")    # => true
"hello world".index("world")        # => 6

# String replacement
"hello world".gsub("world", "Ruby")  # => "hello Ruby"
"hello world".gsub(/[aeiou]/, "*")   # => "h*ll* w*rld"
"hello world".sub("world", "Ruby")   # => "hello Ruby" (first occurrence only)

# String validation
"123".numeric?           # => true (Rails method)
"hello".alpha?           # => true (Rails method)
"hello123".alphanumeric? # => true (Rails method)
"".blank?                # => true (Rails method)
" ".blank?               # => true (Rails method)
nil.blank?               # => true (Rails method)
```

### Regular Expressions
```ruby
# Regex creation
email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
phone_regex = /\A\d{3}-\d{3}-\d{4}\z/

# Regex matching
"john@example.com" =~ email_regex  # => 0 (match at position 0)
"invalid-email" =~ email_regex     # => nil (no match)

# Regex methods
"hello world".match(/world/)       # => #<MatchData "world">
"hello world".scan(/[aeiou]/)      # => ["e", "o", "o"]
"hello world".gsub(/[aeiou]/, "*") # => "h*ll* w*rld"

# Regex groups
match = "John Doe".match(/(\w+)\s+(\w+)/)
match[1]  # => "John"
match[2]  # => "Doe"
```

## File I/O & System Operations

### File Operations
```ruby
# Reading files
content = File.read("file.txt")
lines = File.readlines("file.txt")

# Writing files
File.write("output.txt", "Hello World")
File.open("output.txt", "w") { |file| file.puts "Hello World" }

# Appending to files
File.open("log.txt", "a") { |file| file.puts "New log entry" }

# File information
File.exist?("file.txt")     # => true/false
File.size("file.txt")       # => file size in bytes
File.mtime("file.txt")      # => modification time
File.directory?("path")     # => true/false
File.file?("file.txt")      # => true/false

# Directory operations
Dir.entries(".")            # => array of directory entries
Dir.glob("*.rb")            # => array of .rb files
Dir.mkdir("new_directory")  # => create directory
Dir.rmdir("empty_directory") # => remove empty directory

# File iteration
File.foreach("file.txt") { |line| puts line }
Dir.glob("*.rb").each { |file| puts file }
```

### System Operations
```ruby
# Command execution
result = `ls -la`           # Backticks execute command
result = system("ls -la")   # system() returns true/false
result = %x[ls -la]         # Alternative syntax

# Environment variables
ENV["PATH"]                 # => PATH environment variable
ENV["HOME"] = "/new/home"   # Set environment variable

# Process information
Process.pid                 # => current process ID
Process.ppid                # => parent process ID
Process.uid                 # => user ID
Process.gid                 # => group ID

# Time operations
Time.now                    # => current time
Time.new(2023, 1, 1)        # => specific time
Time.now.to_i               # => Unix timestamp
Time.at(1672531200)         # => Time from Unix timestamp
```

## Metaprogramming

### Dynamic Method Definition
```ruby
class User
  # Define methods dynamically
  %w[name email age].each do |attribute|
    define_method(attribute) do
      instance_variable_get("@#{attribute}")
    end
    
    define_method("#{attribute}=") do |value|
      instance_variable_set("@#{attribute}", value)
    end
  end
end

# Usage
user = User.new
user.name = "John"
puts user.name  # => "John"
```

### Method Missing
```ruby
class User
  def initialize(attributes = {})
    @attributes = attributes
  end
  
  def method_missing(method_name, *args, &block)
    if method_name.to_s.end_with?('=')
      attribute = method_name.to_s.chomp('=')
      @attributes[attribute.to_sym] = args.first
    else
      @attributes[method_name]
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    @attributes.key?(method_name) || @attributes.key?(method_name.to_s.chomp('=').to_sym)
  end
end

# Usage
user = User.new
user.name = "John"
user.email = "john@example.com"
puts user.name   # => "John"
puts user.email  # => "john@example.com"
```

### Class Evaluation
```ruby
# eval (use with caution)
code = "puts 'Hello from eval'"
eval(code)

# instance_eval
user = User.new
user.instance_eval do
  def admin?
    true
  end
end

# class_eval
User.class_eval do
  def self.find_by_name(name)
    # Class method implementation
  end
end
```

### Hooks and Callbacks
```ruby
class User
  def self.inherited(subclass)
    puts "#{subclass} inherited from #{self}"
  end
  
  def self.method_added(method_name)
    puts "Method #{method_name} added to #{self}"
  end
  
  def self.method_removed(method_name)
    puts "Method #{method_name} removed from #{self}"
  end
end

class Admin < User
  def admin_method
    # This will trigger method_added hook
  end
end
```

## Common Interview Questions

### 1. Explain Ruby's object model
**Answer:**
Ruby is a pure object-oriented language where everything is an object, including classes, modules, and even numbers.

```ruby
# Everything is an object
42.class              # => Integer
"hello".class         # => String
true.class            # => TrueClass
nil.class             # => NilClass

# Classes are objects too
String.class          # => Class
Class.class           # => Class

# Objects have methods
42.methods            # => Array of methods
"hello".methods       # => Array of methods
```

### 2. What's the difference between `include` and `extend`?
**Answer:**
- `include`: Adds module methods as instance methods
- `extend`: Adds module methods as class methods

```ruby
module Greetable
  def greet
    "Hello!"
  end
end

class Person
  include Greetable  # greet becomes instance method
end

class Robot
  extend Greetable   # greet becomes class method
end

person = Person.new
person.greet         # => "Hello!"

Robot.greet          # => "Hello!"
```

### 3. Explain Ruby's method lookup path
**Answer:**
Ruby follows a specific order when looking for methods:
1. Singleton methods
2. Methods from included modules (last included first)
3. Methods from the class
4. Methods from superclass
5. Methods from superclass modules
6. `method_missing`

```ruby
module A
  def method_a
    "A"
  end
end

module B
  def method_b
    "B"
  end
end

class Parent
  include A
  
  def method_parent
    "Parent"
  end
end

class Child < Parent
  include B
  
  def method_child
    "Child"
  end
end

# Method lookup order for Child instance:
# 1. Child methods
# 2. B methods
# 3. Parent methods
# 4. A methods
# 5. Object methods
# 6. Kernel methods
```

### 4. What are blocks, procs, and lambdas?
**Answer:**
- **Blocks**: Anonymous code blocks passed to methods
- **Procs**: Stored blocks that can be passed around
- **Lambdas**: Strict procs with argument checking

```ruby
# Block
[1, 2, 3].each { |x| puts x }

# Proc
my_proc = Proc.new { |x| x * 2 }
[1, 2, 3].map(&my_proc)

# Lambda
my_lambda = lambda { |x| x * 2 }
[1, 2, 3].map(&my_lambda)

# Differences
proc = Proc.new { |x, y| puts x, y }
lambda_proc = lambda { |x, y| puts x, y }

proc.call(1)        # Works (y becomes nil)
lambda_proc.call(1) # Raises ArgumentError
```

### 5. How do you handle memory management in Ruby?
**Answer:**
Ruby uses garbage collection, but you can help by:
- Avoiding object retention
- Using weak references
- Clearing large objects
- Using appropriate data structures

```ruby
# Bad: Retaining large objects
def process_data
  large_array = (1..1000000).to_a
  # large_array is retained until method returns
end

# Good: Process in chunks
def process_data
  (1..1000000).each_slice(1000) do |chunk|
    process_chunk(chunk)
  end
end

# Force garbage collection
GC.start

# Check memory usage
puts GC.stat
```

### 6. Explain Ruby's threading model
**Answer:**
Ruby has a Global Interpreter Lock (GIL) that prevents true parallelism for CPU-bound tasks, but allows concurrency for I/O-bound tasks.

```ruby
# Thread creation
thread = Thread.new do
  puts "Hello from thread"
end

thread.join  # Wait for thread to complete

# Thread safety
@counter = 0
mutex = Mutex.new

10.times do
  Thread.new do
    mutex.synchronize do
      @counter += 1
    end
  end
end

# Wait for all threads
Thread.list.each(&:join)
puts @counter  # => 10
```

### 7. What's the difference between `==`, `===`, `eql?`, and `equal?`?
**Answer:**
- `==`: Value equality
- `===`: Case equality (used in case statements)
- `eql?`: Value and type equality
- `equal?`: Object identity equality

```ruby
a = "hello"
b = "hello"
c = a

a == b        # => true (same value)
a === b       # => true (case equality)
a.eql?(b)     # => true (same value and type)
a.equal?(b)   # => false (different objects)
a.equal?(c)   # => true (same object)

# Case equality examples
(1..10) === 5     # => true
String === "hello" # => true
/hello/ === "hello world" # => true
```

### 8. How do you implement singleton pattern in Ruby?
**Answer:**
Ruby provides a built-in `Singleton` module:

```ruby
require 'singleton'

class DatabaseConnection
  include Singleton
  
  def initialize
    @connection = "Connected to database"
  end
  
  def query(sql)
    "Executing: #{sql}"
  end
end

# Usage
db1 = DatabaseConnection.instance
db2 = DatabaseConnection.instance
db1.equal?(db2)  # => true (same instance)
```

### 9. Explain Ruby's method visibility
**Answer:**
Ruby has three levels of method visibility:
- `public`: Accessible from anywhere
- `protected`: Accessible from same class or subclasses
- `private`: Accessible only from within the same instance

```ruby
class User
  def public_method
    "This is public"
  end
  
  protected
  
  def protected_method
    "This is protected"
  end
  
  private
  
  def private_method
    "This is private"
  end
end

class Admin < User
  def test_visibility
    public_method      # => Works
    protected_method   # => Works (same class hierarchy)
    private_method     # => Works (same instance)
  end
end
```

### 10. How do you handle exceptions in Ruby?
**Answer:**
Ruby uses `begin/rescue/ensure/else` blocks for exception handling:

```ruby
begin
  # Code that might raise an exception
  result = 10 / 0
rescue ZeroDivisionError => e
  puts "Division by zero: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
else
  puts "No exception occurred"
ensure
  puts "This always runs"
end

# Custom exceptions
class ValidationError < StandardError
  attr_reader :field, :value
  
  def initialize(field, value, message = "Validation failed")
    @field = field
    @value = value
    super("#{message} for #{field}: #{value}")
  end
end
```

## Best Practices Summary

### Code Style
1. **Use snake_case** for variables and methods
2. **Use PascalCase** for classes and modules
3. **Use UPPER_CASE** for constants
4. **Use meaningful names** for variables and methods
5. **Keep methods short** and focused

### Performance
1. **Avoid unnecessary object creation**
2. **Use appropriate data structures**
3. **Profile before optimizing**
4. **Use lazy evaluation** when possible
5. **Cache expensive calculations**

### Error Handling
1. **Use specific exception types**
2. **Provide meaningful error messages**
3. **Handle exceptions at appropriate levels**
4. **Use ensure blocks** for cleanup
5. **Log errors appropriately**

### Testing
1. **Write tests for all public methods**
2. **Test edge cases and error conditions**
3. **Use descriptive test names**
4. **Keep tests simple and focused**
5. **Mock external dependencies**

Remember: Ruby is a powerful and flexible language. Understanding these fundamentals will help you write better Ruby code and excel in Ruby-related interviews. Practice these concepts regularly and build projects to reinforce your learning.


