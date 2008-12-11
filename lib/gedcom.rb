# -------------------------------------------------------------------------
# gedcom.rb -- core module definition of GEDCOM-Ruby interface
# Copyright (C) 2003 Jamis Buck (jgb3@email.byu.edu)
# -------------------------------------------------------------------------
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------

require 'gedcom_date'

module GEDCOM

  # Possibly a better way to do this?
  VERSION = "0.2.1"
	
  class Parser
    def initialize &block
      @before = {}
      @after = {}
      @ctxStack = []
      @dataStack = []
      @curlvl = -1
      instance_eval(&block) if block_given?
    end

    def before tag, proc=nil, &block
      proc = check_proc_or_block proc, &block
      @before[[tag].flatten] = proc
    end

    def after tag, proc=nil, &block
      proc = check_proc_or_block proc, &block
      @after[[tag].flatten] = proc
    end

    def parse( file )
      case file
      when String
        parse_file(file)
      when IO
        parse_io(file)
      else
        raise ArgumentError.new("requires a String or IO")
      end
    end

    def context
      @ctxStack
    end


    protected
    
    def check_proc_or_block proc, &block
      unless proc or block_given?
        raise ArgumentError.new("proc or block required")
      end
      proc = method(proc) if proc.kind_of? Symbol
      proc ||= Proc.new(&block)
    end

    def parse_file(file)
      File.open( file, "r" ) do |io|
        parse_io(io)
      end
    end

    def parse_io(io)
      io.each_line do |line|
        level, tag, rest = line.chop.split( ' ', 3 )
        level = level.to_i
        unwind_to level

        tag, rest = rest, tag if tag =~ /@.*@/

        @ctxStack.push tag
        @dataStack.push rest
        @curlvl = level

        do_before @ctxStack, rest
      end
      unwind_to -1
    end

    def unwind_to level
      while level <= @curlvl
        do_after @ctxStack, @dataStack.last
        @ctxStack.pop
        @dataStack.pop
        @curlvl -= 1
      end
    end

    def do_before tag, data
      if proc = @before[tag]
        proc.call data
      elsif proc = @before[ANY]
        proc.call tag, data
      end
    end

    def do_after tag, data
      if proc = @after[tag]
        proc.call data
      elsif proc = @after[ANY]
        proc.call tag, data
      end
    end

    ANY = [:any]
  end #/ Parser

end #/ GEDCOM

