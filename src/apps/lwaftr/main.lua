local app = require("core.app")
local config = require("core.config")
local pcap = require("apps.pcap.pcap")
local lwaftr = require("apps.lwaftr.lwaftr")
local ipv6 = require("lib.protocol.ipv6")

local conf = require("apps.lwaftr.conf")

local usage="thisapp conf_file in.pcap out.pcap"

function run (parameters)
   if not (#parameters == 3) then print(usage) main.exit(1) end
   local conf_file = parameters[1]
   local in_pcap = parameters[2]
   local out_pcap = parameters[3]

   local aftrconf = conf.get_aftrconf(conf_file)

   local c = config.new()
   config.app(c, "capture", pcap.PcapReader, in_pcap)
   config.app(c, "lwaftr", lwaftr.LwAftr, aftrconf)
   config.app(c, "output_file", pcap.PcapWriter, out_pcap)

   config.link(c, "capture.output -> lwaftr.input")
   config.link(c, "lwaftr.output -> output_file.input")

   app.configure(c)
   app.main({duration=1})
   print("done")
end

run(main.parameters)
