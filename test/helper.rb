require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/unit'
require 'shoulda'
require 'shoulda-context'
require 'mocha/setup'


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bio-statsample-glm'
module MiniTest
  class Unit
    class TestCase
      include Shoulda::Context::Assertions
      include Shoulda::Context::InstanceMethods
      extend Shoulda::Context::ClassMethods
      def self.should_with_gsl(name,&block)
        should(name) do
          if Statsample.has_gsl?
            instance_eval(&block)
          else
            skip("Requires GSL")
          end
        end
      end
    end
  end

  module Assertions
    def assert_similar_vector(exp, obs, delta=1e-10,msg=nil)
      msg||="Different vectors #{exp} - #{obs}"
      assert_equal(exp.size, obs.size)
      exp.data_with_nils.each_with_index {|v,i|
        assert_in_delta(v,obs[i],delta)
      }
    end
    def assert_similar_hash(exp, obs, delta=1e-10,msg=nil)
      msg||="Different hash #{exp} - #{obs}"
      assert_equal(exp.size, obs.size)
      exp.each_key {|k|
        assert_in_delta(exp[k],obs[k],delta)
      }
    end

    def assert_equal_vector(exp,obs,delta=1e-10,msg=nil)
      assert_equal(exp.size, obs.size, "Different size.#{msg}")
      exp.size.times {|i|
        assert_in_delta(exp[i],obs[i],delta, "Different element #{i}. \nExpected:\n#{exp}\nObserved:\n#{obs}.#{msg}")
      }
    end
    def assert_equal_matrix(exp,obs,delta=1e-10,msg=nil)
      assert_equal(exp.row_size, obs.row_size, "Different row size.#{msg}")
      assert_equal(exp.column_size, obs.column_size, "Different column size.#{msg}")
      exp.row_size.times {|i|
        exp.column_size.times {|j|
          assert_in_delta(exp[i,j],obs[i,j], delta, "Different element #{i},#{j}\nExpected:\n#{exp}\nObserved:\n#{obs}.#{msg}")
        }
      }
    end
    alias :assert_raise :assert_raises unless method_defined? :assert_raise
    alias :assert_not_equal :refute_equal unless method_defined? :assert_not_equal
    alias :assert_not_same :refute_same unless method_defined? :assert_not_same
    unless method_defined? :assert_nothing_raised
      def assert_nothing_raised(msg=nil)
        msg||="Nothing should be raised, but raised %s"
        begin
          yield
          not_raised=true
        rescue Exception => e
          not_raised=false
          msg=sprintf(msg,e)
        end
        assert(not_raised,msg)
      end
    end
  end
end

MiniTest::Unit.autorun
