## Collaborate and Innovate

Requirements: Netlogo 6.4

Intended to be a simplified model of innovation driven by collaboration.   The design was documented in design.md, which describes the initial design. This was modified during development to provide a more central role for the `idea` bitvectors: when an innovator successfully collaborates with another innovator, it modifies its idea to more closely match the other innovator.  In this implementation this is done via 'uniform crossover' where each bit in the new bitvector is chosen at random from the collaborators bitvectors.  

More details are available in the Netlogo 'info' tab.