#! /usr/bin/env lua
--
-- c.lua
-- Copyright (C) 2016 Adrian Perez <aperez@igalia.com>
--
-- Distributed under terms of the MIT license.
--

local ffi = require "ffi"

ffi.cdef [[
void* malloc(size_t size);
void  free(void *ptr);

typedef enum {
   NDPI_PROTOCOL_SAFE,
   NDPI_PROTOCOL_ACCEPTABLE,
   NDPI_PROTOCOL_FUN,
   NDPI_PROTOCOL_UNSAFE,
   NDPI_PROTOCOL_POTENTIALLY_DANGEROUS,
   NDPI_PROTOCOL_UNRATED,
} ndpi_protocol_breed_t;

typedef struct ndpi_id_struct ndpi_id_t;
typedef struct ndpi_flow_struct ndpi_flow_t;
typedef struct ndpi_detection_module_struct ndpi_detection_module_t;
typedef struct ndpi_protocol_bitmask_struct ndpi_protocol_bitmask_t;
typedef struct { uint16_t master_protocol, protocol; } ndpi_protocol_t;

const char* ndpi_revision (void);

uint32_t ndpi_detection_get_sizeof_ndpi_flow_struct (void);
void     ndpi_free_flow (ndpi_flow_t *flow);

uint32_t ndpi_detection_get_sizeof_ndpi_id_struct (void);

ndpi_detection_module_t* ndpi_init_detection_module (uint32_t ticks_per_second,
                                                     void *ndpi_malloc,
                                                     void *ndpi_free,
                                                     void *ndpi_debug);

void ndpi_exit_detection_module (ndpi_detection_module_t *detection_module,
                                 void *ndpi_free__dummy);

void ndpi_set_protocol_detection_bitmask2 (ndpi_detection_module_t *detection_module,
                                           const ndpi_protocol_bitmask_t *bitmask);

ndpi_protocol_t ndpi_detection_process_packet (ndpi_detection_module_t *detection_module,
                                               ndpi_flow_t *flow,
                                               const uint8_t *packet,
                                               unsigned short packetlen,
                                               uint64_t current_tick,
                                               ndpi_id_t *src,
                                               ndpi_id_t *dst);

void ndpi_dump_protocols (ndpi_detection_module_t *detection_module);

int ndpi_load_protocols_file (ndpi_detection_module_t *detection_module,
                              const char *path);

ndpi_protocol_t ndpi_find_port_based_protocol (ndpi_detection_module_t *detection_module,
                                               uint8_t protocol,
                                               uint32_t src_host, uint16_t src_port,
                                               uint32_t dst_host, uint32_t dst_port);

ndpi_protocol_t ndpi_guess_undetected_protocol (ndpi_detection_module_t *detection_module,
                                                uint8_t protocol,
                                                uint32_t src_host, uint16_t src_port,
                                                uint32_t dst_host, uint32_t dst_port);

ndpi_protocol_breed_t ndpi_get_proto_breed (ndpi_detection_module_t *detection_module,
                                            uint16_t protocol);

const char* ndpi_get_proto_breed_name (ndpi_detection_module_t *detection_module,
                                       ndpi_protocol_breed_t breed_id);

const char* ndpi_get_proto_name (ndpi_detection_module_t *detection_module,
                                 uint16_t protocol_id);

int ndpi_get_protocol_id (ndpi_detection_module_t *detection_module, const char *name);
]]

return ffi.load("ndpi")
