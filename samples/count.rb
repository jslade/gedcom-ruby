#!/usr/bin/ruby -Ilib

# -------------------------------------------------------------------------
# count.rb: program demonstrating the GEDCOM library.
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
# Run this program by passing it the name of a GEDCOM file.  It will print
# out the number of individuals and families in the file.
# -------------------------------------------------------------------------

require 'gedcom'

if ARGV.length < 1
  puts "Please specify the name of a GEDCOM file."
  exit(0)
end

puts "Parsing '#{ARGV[0]}'..."

individuals = 0
families = 0

parser = GEDCOM::Parser.new do
  before "INDI" do
    individuals += 1
  end

  before "FAM" do
    families += 1
  end
end

parser.parse ARGV[0]

puts "There are #{individuals} individuals and #{families} families in '#{ARGV[0]}'."
