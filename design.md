## High level design.


(1) What part of your phenomenon would you like to build a model of?  Make sure that the phenomenon is appropriate for an agent-based model that could be completed in the next month.

The phenomenon I want to build a model of is the effect of collaboration on innovation. The part I want to focus on is the effect of restricting (or promoting) collaboration on the rate of innovation in an artificial innovation ecosystem.   

(2) What are the principal types of agents involved in this phenomenon?  Illustrate all of the agent types necessary for the model.

There will be only two type of agents: 'Innovators' and 'Social connections'. Innovators will try to get their idea launched by collaborating with other Innovators on a social network. The 'Social connections' (Links in the social network) are a proto-agent and will have no properties or behaviors in this initial model. 

(3)   What properties do these agents have (describe by agent type)?  Describe for all agent types.

* Innovators: 
  * `Idea`: Represented by either a size `n_idea` bitvector or a vector in a `n_idea` dimensional space.   (Design choice to be made later). These will be generated randomly.  For example, if `n_idea` is 8 and we are using bitvectors, an idea might be `01101111`

  * Collaboration Threshold (`C_t`): The number of successful collaborations needed to successfully 'innovate' (launch the idea).  This can be fixed or be a random number from 1 to `C_max`  (Design choice to be made later).

  * Collaboration progress (`C_p`): The number of successful collaborations achieved.  This will be initialized to 0.

  * Time steps counter (`T`): The number of time steps that have elapsed while trying to launch the idea.  If `T` reaches a maximum value `T_max` (a global), the idea will fail and Innovator will reset their idea and threshold.

* Social connections are proto-agents without properties.

(4)   What actions (or behaviors) can these agents take (describe by agent type)? Describe all appropriate behaviors for all agent types.

* Innovators:
  
  Innovators will try to collaborate with other Innovators on the network. If they can make a connection, they will compare their ideas and if they are similar enough, they will both increase their 'collaboration progress' by 1.  If they are not similar enough, nothing will happen.  If the collaboration progresses reaches the collaboration threshold,  they will launch their idea and we will count this as a successful innovation.  The Innovator will then choose a new random idea and new threshold.  If an Innovator has not launched their idea after a certain number of time steps (`T_max`), this will count as a failure and the Innovator will reset their idea and threshold. 

  As an optional idea, successful collaboration could result in a new direct link between the two Innovators in the network. 

  Another optional idea (stretch) is that Innovators with successful innovations could be more likely to be chosen as collaborators in the future, perhaps getting a bonus to the probability of collaboration attempt.

* Social connections have no behaviors

(5)   In what kind of environment do these agents operate? Describe the basic environment type (e.g., spatial, network, featurespace, etc.) and fully describe the environment.

The agents will operate in a network environment.  The network will be a generated undirected graph with a fixed number of nodes (`N_innovators`) and with a user selected generation algorithm to determine the social connections. Most likely we will focus on the Barabasi-Albert preferential attachment model as that seems to have the good approximation for social networks. 

(6)   If you had to “discretize” the phenomenon into time steps, what events and in what order would occur during any one time step? Fully describe everything that happens during a time step.

During each time step:

For each Innovator:

* Each Innovator chooses a random Innovator to try and collaborate with.

* We first determine if a collaboration attempt can be made. This is determined distance in hops between the two Innovators on the network. The probability of a connection will be `p^n`, where n is the number of hops between the two Innovators and `p` is a parameter of the model. This represents the difficulty of communicating with other Innovators.

* If the connection is successful, we then determine if collaboration can occur based on the similarity of the two Innovators' ideas. The similarity measure and probability of successful collaboration depend on the representation of ideas:

     * Vector Representation: For ideas represented as vectors in an `n_idea` dimensional space, cosine similarity will be used. The probability of successful collaboration will be proportional to this similarity measure.

     * Bitvector Representation: For ideas represented as bitvectors, the Hamming distance will be used. The probability of successful collaboration will be ( 1 - Hamming distance / n_idea).

* If the collaboration is successful, we will increase the collaboration progress  `C_p` of both Innovators by 1.  If they are not, nothing will happen.

* If the collaboration progress reaches the threshold `C_t`, the Innovator will launch their idea and we will count this as a successful innovation.  The Innovator will then choose a new random idea and new threshold.

* The time steps taken `T` is incremented, and if this is greater then `T_max`, this will count as a failure and the Innovator will reset their idea and threshold.

* Optionally, when there is a successful collaboration,  we could create a new direct link between the two Innovators in the network, or do so with some probability that depends on the similarity score. 

(7)   What are the inputs to the model? Identify all relevant inputs.

Key inputs to the model include:

- The network generation algorithm  (e.g. Barabasi-Albert, Watts-Strogatz, Erdos-Renyi).

- Connectivity in the network (e.g. connection density, but the parameter set will depend on the network generation algorithm)

- The probability of collaboration (per hop `p`)

- The size of the innovation space, `n_idea` and the type of space (e.g. bitvector, vector)

- The maximum number of collaborations that are needed to launch an idea, `N_max`. 

- The maximum time to launch an idea, `T_max`

Other inputs include:

- The number of Innovators, `N_innovators`

- The precise form of the similarity measure between ideas (e.g. cosine similarity, Hamming distance)



(8)   What do you hope to observe from this model? Identify all relevant outputs.

- The most important outputs are the rate of innovation success and failure.  I hope to observe how this rate changes as we vary the inputs to the model, in particular the probability of collaboration `p`.   This could represent the effect of policies that promote or restrict communication between Innovators.

- In addition I would like to look at the impact on the rate of innovation (and failures) if we mutilate the network, for example by removing some nodes at random that represent  'high risk' nodes or 'bad actors'.  This will be a measure of the robustness of the innovation ecosystem to more severe restrictions on communication. Perhaps we could also look at the impact of removing nodes with the highest degree, which could represent the effect of removing the most connected Innovators from the network. 

 
