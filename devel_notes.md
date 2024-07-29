## First model

First model July 29 illustrates how innovation rate depends on the network structure and the probability of innovation, but the rate settles down quite quickly.

Note that parameters should be adjusted so that there are a few ticks (?) between successeful innovations. In this regime the histogram of innovations by firm is more power law ish.  In regimes were several innovations happen in a row, the histogram is approximately normal centered on the mean number of innovations per firm.  



  I may want to have a model that changes the network over time?  Some ideas:

* Add new connections (as discussed previously)

* Kill off innovators that fail too many times 

* Add new innovators to the network  to replace those that fail. Preferentially to the ones with highest success rate?

## Analysis to consider:

* How does the rate of innovation change as we vary the probability of collaboration `p`?

* How does the rate of innovation change as we vary the network structure?

* How does the rate of innovation change as we vary the similarity measure between ideas?

* what is the distribution of innovation success among the innovators?  Is it a power law? How does it depend on the network statistics for that firm? (Centrality, clustering, etc)

* distribution of innovation time  ? How many ticks to succeed?  How does this depend on the firms network statistics?  