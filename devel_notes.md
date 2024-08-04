## Development in progress

First model July 29 illustrates how innovation rate depends on the network structure and the probability of innovation, but the rate settles down quite quickly.

Note that parameters should be adjusted so that there are a few ticks (?) between successful innovations. In this regime the histogram of innovations by firm is more power law ish.  In regimes were several innovations happen in a row, the histogram is approximately normal centered on the mean number of innovations per firm.  

## TODO:

- Add plots of succ-rate vs some centrality measures

- Add documentation

- Add more tests

- Maybe forget about the histogram of n-innovations

## Analysis to consider:

* How does the rate of innovation change as we vary the probability of collaboration `p`?

* How does the rate of innovation change as we vary the network structure?

* How does the rate of innovation change as we vary the similarity measure between ideas?

* what is the distribution of innovation success among the innovators?  Is it a power law? How does it depend on the network statistics for that firm? (Centrality, clustering, etc)

* Plot success-rate vs centrality measures

* distribution of innovation time  ? How many ticks to succeed?  How does this depend on the firms network statistics?  