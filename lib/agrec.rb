require "agrec/version"
require 'json'
require 'rexml/document'
require 'open-uri'
require 'pp'
require 'thread'


module Agrec
    class Client
        SERVER_LIST = ["rtmp://fms-base1.mitene.ad.jp/agqr/aandg11", "rtmp://fms-base2.mitene.ad.jp/agqr/aandg11", "rtmp://fms-base2.mitene.ad.jp/agqr/aandg22"]
        def initialize(**args)
            @save_dir = "."
            @save_dir = args[:save_dir] if args[:rtmpdump] != nil
            @rtmpdump_path = args[:rtmpdump] if args[:rtmpdump] != nil
        end

        def start
            @record_thread = Thread.new(SERVER_LIST[i], &method(:record)) unless isAlive?
        end

        def stop
            Thread.kill(@record_thread)
        end

        def isAlive?
            @record_thread.alive?
        end

        private


        def parse_var text
            ret = {}
            text.split("\n").each do |line|
                words = line.split
                ret[words[1]] = words[3].force_encoding("utf-8").gsub(/(\;|\')/, "") if words[3] != nil
            end
            ret
        end

        def get_program
            url = "http://www.uniqueradio.jp/aandg"
            json = open(url) do |f|
                f.read
            end
            res = URI.unescape(json)
            parse_var res
        end

        def record url
            filename = "tmp"
            if @rtmpdump_path.nil?
                system("rtmpdump -r #{url} --live -o #{@save_dir}/#{filename}.flv")
            else
                puts "#{@rtmpdump_path} -r #{url} --live -o #{@save_dir}/#{filename}.flv"
                if system("#{@rtmpdump_path} -r #{url} --live -o #{@save_dir}/#{filename}.flv")
                    puts "RECORD SUCCESS"
                else
                    puts "RTMPDUMP STOP"
                end
            end

        end
    end
end
