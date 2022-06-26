#! /usr/bin/ruby

str = ARGV[0]
clientPid = Process.pid

if str == nil then
    abort "Enter args"
end

#server
pid = fork do
    c = ""
    trap("USR1") do
        c << "0"
        if (c.length >= 8) then
            print  "%c" % c.to_i(2)
            c = ""
        end
        Process.kill("USR1", clientPid)
    end
    trap("USR2") do
        c << "1"
        if (c.length >= 8) then
            print  "%c" % c.to_i(2)
            c = ""
        end
        Process.kill("USR1", clientPid)
    end

    trap("SIGINT") do
        abort 
    end

    while true do
    end
end

server_confirm = 1

trap("USR1") do
    server_confirm = 1
end

trap("SIGINT") do
    abort 
end

str.each_byte { |c|
    c.to_s(2).rjust(8, "0").split("").each { |bit|
        sig = bit == "0" ? "USR1" : "USR2" 
        Process.kill(sig, pid)
        server_confirm = 0
        while server_confirm == 0 do
            sleep(0.005)
        end
    }
}