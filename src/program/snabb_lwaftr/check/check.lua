module(..., package.seeall)

local app = require("core.app")
local config = require("core.config")
local lib = require("core.lib")
local pcap = require("apps.pcap.pcap")
local lwaftr = require("apps.lwaftr.lwaftr")
local bt = require("apps.lwaftr.binding_table")
local conf = require("apps.lwaftr.conf")

function show_usage(code)
   print(require("program.snabb_lwaftr.check.README_inc"))
   main.exit(code)
end

function parse_args(args)
   local handlers = {}
   function handlers.h() show_usage(0) end
   args = lib.dogetopt(args, handlers, "h", { help="h" })
   if #args ~= 6 then show_usage(1) end
   return unpack(args)
end

function run(args)
   local bt_file, conf_file, inv4_pcap, inv6_pcap, outv4_pcap, outv6_pcap =
      parse_args(args)

   -- It's essential to initialize the binding table before the aftrconf
   bt.get_binding_table(bt_file)
   local aftrconf = conf.get_aftrconf(conf_file)

   local c = config.new()
   config.app(c, "capturev4", pcap.PcapReader, inv4_pcap)
   config.app(c, "capturev6", pcap.PcapReader, inv6_pcap)
   config.app(c, "lwaftr", lwaftr.LwAftr, aftrconf)
   config.app(c, "output_filev4", pcap.PcapWriter, outv4_pcap)
   config.app(c, "output_filev6", pcap.PcapWriter, outv6_pcap)

   config.link(c, "capturev4.output -> lwaftr.v4")
   config.link(c, "capturev6.output -> lwaftr.v6")
   config.link(c, "lwaftr.v4 -> output_filev4.input")
   config.link(c, "lwaftr.v6 -> output_filev6.input")

   app.configure(c)
   app.main({duration=0.10})
   print("done")
end