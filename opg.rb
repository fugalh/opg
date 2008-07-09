#! /usr/bin/ruby
require 'ostruct'
require 'erb'

opts = []
ARGF.each_line do |line|
  line.strip!
  short, long, help = line.split($;, 3)
  raise "Bad short '#{short}'" unless short =~ /^-?(\w)$/
  short = $1
  raise "Bad long '#{long}'" unless long =~ /^(--)?(\w+)(=([\w*]+(\?)?))?$/
  long = $2
  type = ($4 or 'bool')
  required = $5.nil?
  type = type[0..-2] unless required
  raise "Bad type '#{type}'" unless type =~ /^(char\*|int|float|bool)$/
  opts.push OpenStruct.new(:short => short, :long => long, :help => help,
                           :tipe => type, :required => required)
end

template = ERB.new <<-EOF
#include <getopt.h>
#include <string.h>
#include <inttypes.h>
#include <stdlib.h>

struct options {
    <% opts.each do |o| 
        t = o.tipe
        t = 'int' if t == 'bool'
    %>
    <%= t %> <%= o.short %>; /* <%= o.long %> */
    <% end %>
};

void usage(void)
{
    puts("Options:");
<% 
longs = opts.map{|o| "--" + o.long + (o.tipe == 'bool' ? '' : (o.required ? "=" + o.tipe : "[=" + o.tipe + "]"))}
longest = longs.map{|l| l.size}.max 
shorts = opts.map{|o| "-" + o.short}
helps = opts.map{|o| o.help}
shorts.zip(longs, helps).each do |s,l,h|
  msg = sprintf("  %s  %-" + longest.to_s + "s  %s", s, l, h)    
%>
    puts("<%= msg %>");
<% end %>
    puts("  -h  --help");
    exit(1);
}

void parse_options(int argc, char * const *argv, struct options *opts)
{
    struct option longopts[] = {
        <% opts.each do |o|
            arg = 'optional_argument'
            arg = 'required_argument' if o.required
            arg = 'no_argument' if o.tipe == 'bool'
        %>
        { "<%= o.long %>", <%= arg %>, 0, '<%= o.short %>' },
        <% end %>
        {0,0,0,0}
    };

    <% optstring = opts.map{|o| o.short + (o.tipe == 'bool' ? "" : (o.required ? ":" : "::"))}.join %>
    int ch;
    while ((ch = getopt_long(argc, argv, "h<%= optstring %>", longopts, 0)) != -1)
    {
        switch (ch) {
      <% opts.each do |o| %>
        case '<%= o.short %>':
        <% case o.tipe
           when 'float' %>
            if (optarg == 0)
                opts-><%= o.short %> = 0;
            else
                opts-><%= o.short %> = strtof(optarg, 0);
        <% when 'int' %>
            if (optarg == 0)
                opts-><%= o.short %> = 0;
            else
                opts-><%= o.short %> = strtol(optarg, 0, 0);
        <% when 'char*' %>
            if (optarg == 0)
                opts-><%= o.short %> = 0;
            else
            {
                opts-><%= o.short %> = malloc(strlen(optarg)+1);
                strncpy(opts-><%= o.short %>, optarg, strlen(optarg));
            }
        <% when 'bool' %>
            opts-><%= o.short %> = 1;
        <% else 
             raise "Shouldn't happen"
           end 
        %>
            break;
      <% end %>
        default:
            usage();
        }
    }
}
EOF

puts template.result(binding)
