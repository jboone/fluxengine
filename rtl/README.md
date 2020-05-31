# Notes on Simulation

Sorry, I didn't bother to write a proper Makefile. I'm terrible at Makefiles.

Once you have iverilog and GTKwave installed, here's how you'd build and simulate:

First, build a simulation binary (Sampler_tb) from the necessary Verilog source files.

```
$ iverilog Sampler_before.v Sampler_after.v Sampler_tb.v -o Sampler_tb
```

Then, run the simulator, which will run for the duration specified in the testbench, and produce a .fst file, which is a new and more efficient form of .vcd (another simulation output file format).

```
$ vvp -N Sampler_tb -fst +fst=Sampler_tb.fst
```

It can take a while, because I'm simulating a LOT of clock cycles to test a wide range of 64 MHz pulse intervals.

Then, simulate using GTKwave.

```
$ gtkwave Sampler_tb.fst
```

GTKwave is a lot like the commercial simulation packages I've used. It's definitely an eccentric user interface.

First you need to drag signals from the tree view that contains all the modules and signals from the simulation. Typically, the top level module is the testbench, and has the stimulous signals. The child modules are the units you're testing. I have two units in there to compare -- the old implementation and the new implementation. So you can see side-by-side how each reacts.

You'll notice I have the two implementations in two separate files. Neither file comes from the rest of the repo. They're just copied over and edited. I did this for the old implementation because it does some includes at the top that I didn't want to work around. I probably could've made empty files with the same name inside the simulation directory as a hack, but... Eh.

Also note that when GTKwave starts, it's zoomed *way* in. You'll be looking across a span of a few picoseconds. So be sure to zoom out...

I hope that gets you on your way to simulating Verilog projects!
