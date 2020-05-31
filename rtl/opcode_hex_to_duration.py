#!/usr/bin/env python3

import sys

import numpy

system_clock = 64e6
# system_clock = 12e6
sample_clock = 12e6

def opcodes_to_timestamps_old(file_path):
	timestamps = []

	t = 0
	with open(file_path) as f:
		for line in f:
			v = int(line.strip(), 16)
			delta = v & 0x3f
			t += delta

			if v & 0xc0:
				timestamps.append(t)
				t = 0

	return timestamps

def opcodes_to_timestamps(file_path):
	opcodes = numpy.fromfile(file_path, dtype=numpy.uint8)
	ticks = numpy.cumsum(opcodes & 0x3f, dtype=numpy.uint32)
	ticks_rdata = numpy.extract(opcodes & 0x80, ticks)
	return ticks_rdata

timestamps_pulses = numpy.fromfile('ticks.u32', dtype=numpy.uint32)
timestamps_before = opcodes_to_timestamps('before_opcodes.u8')
timestamps_after  = opcodes_to_timestamps('after_opcodes.u8' )

timestamps_pulses = numpy.array(timestamps_pulses, dtype=numpy.float32) * sample_clock / system_clock

import matplotlib.pyplot as plt

plt.plot(timestamps_pulses, label='Ideal')
plt.plot(timestamps_before, label='Before')
plt.plot(timestamps_after,  label='After' )
# plt.plot(timestamps_pulses[:-3] / timestamps_after)
# plt.plot(
# 	(0, len(timestamps_before)),
# 	(0 * sample_clock / system_clock, (len(timestamps_before)) * sample_clock / system_clock),
# 	label='Perfect'
# )
plt.legend(loc='upper left')
plt.xlabel('System Clock Ticks ({:2.0f} MHz)'.format(system_clock / 1e6))
plt.ylabel('Sample Ticks ({:2.0f} MHz)'.format(sample_clock / 1e6))
plt.show()
