#! /usr/bin/ruby

str = ARGV[0]
clientPid = Process.pid

#server
pid = fork do
    c = ""
    trap("USR1") do
        if (c.length >= 8) then
            print  "%c" % c.to_i(2)
            c = ""
        end
        c << "0"
        Process.kill("USR1", clientPid)
    end
    trap("USR2") do
        if (c.length >= 8) then
            print  "%c" % c.to_i(2)
            c = ""
        end
        c << "1"
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