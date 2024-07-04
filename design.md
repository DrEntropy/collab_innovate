## High level design.


(1) What part of your phenomenon would you like to build a model of?  Make sure that the phenomenon is appropriate for an agent-based model that could be completed in the next month.

The phenomenon I want to build a model of is the effect of collaboration on innovation. The part I want to focus on is the effect of restricting (or promoting) collaboration on the rate of innovation in an artificial innovation ecosystem.   

(2) What are the principal types of agents involved in this phenomenon?  Illustrate all of the agent types necessary for the model.

There will be only one type of agents: 'Innovators' Innovators will try to get their idea launched by collaborating with other Innovators on a social network.

(3)   What properties do these agents have (describe by agent type)?  Describe for all agent types.

* Innovators: 
  * Have an idea that they want to launch, which will be represnted by a size `n_idea` bitvector or a vector in a `n_idea` dimensional space.  (Design choice to be made later). 

  * Have a collaboration threshiold `C_t` that they need to meet to launch their idea, which is the number of successuful collaborations they need to have before they can launch their idea.  This can be fixed or be a random number from 1 to `C_max`  (Design choice to be made later).

  * Have a 'collaboration progress' `C_p` which is the number of successful collaborations they have had.  This will be initialized to 0.

  * Have a counter `T` which is the number of time steps they have been trying to launch their idea.  If `T` reaches a maximum value `T_max`, the idea will fail and Innovator will reset their idea and threshold.


(4)   What actions (or behaviors) can these agents take (describe by agent type)? Describe all appropriate behaviors for all agent types.

* Innovators:
  
  Innovators will try to collaborate with other Innovators on the network. If they can make a connection, they will compare their ideas and if they are similar enough, they will both increase their 'collaboration progress' by 1.  If they are not similar enough, nothing will happen.  If the collaboration progresses reaches the collaboration threshold,  they will launch their idea and we will count this as a successful innovation.  The Innovator will then choose a new random idea and new threshold.  If an Innovator has not launched their idea after a certain number of time steps (`T_max`), this will count as a failure and the Innovator will reset their idea and threshold. 

  As an optional idea, successfull collaboration could result in a new direct link between the two Innovators in the network. 

  Another optional idea (stretch) is that Innovators with successful innovations could be more likely to be chosen as collaborators in the future, perhaps getting a bonus to the probability of collaboration attempt.



(5)   In what kind of environment do these agents operate? Describe the basic environment type (e.g., spatial, network, featurespace, etc.) and fully describe the environment.

The agents will operate in a network environment.  The network will be a generated undirected graph with a fixed number of nodes (`N_innovators`) and with a user selected generation algorithm. 

(6)   If you had to “discretize” the phenomenon into time steps, what events and in what order would occur during any one time step? Fully describe everything that happens during a time step.

During each time step:

* Each Innovator chooses a random Innovator to try and collaborate with.

* We first determine if a collaboration attempt can be made. This is determined distance in hops between the two Innovators. The probability of a connection will be `p^n`, where n is the number of hops between the two Innovators and `p` is a parameter of the model. This represnts the difficulty of communicating with other Innovators.

* If the connection is successful, we then determine if we can collaborate with the other Innovator.  This is determined by the similarity of the two Innovators' ideas.  For a vector representation we will use the cosine similarity of the two ideas to determine if they are similar enough to collaborate, while for bitvector we will use the Hamming distance. 

* If the collaboration is successfull, we will increase the 'collaboration progress' of both Innovators by 1.  If they are not, nothing will happen.

* Optionally, we could create a new direct link between the two Innovators in the network, or do so with some probability that depends on the simularity score. 

(7)   What are the inputs to the model? Identify all relevant inputs.

Inputs to the model that we can examine:

- Connectivity in the network (e.g. connection density, but the paramater set will depend on the network generation algorithm)

- The probability of collaboration (per hop `p`)

- The size of the innovation space, `n_idea`

- The maximum number of collaborations that are needed to launch an idea, `N_max`. 

(8)   What do you hope to observe from this model? Identify all relevant outputs.

- The most important output is the rate of innovation, which is the number of successful innovations per time step.   I hope to observe how this rate changes as we vary the inputs to the model, in particular the probability of collaboration `p`.  

- We also will look at the failure rate of Innovators, which is the number of Innovators that have not launched their idea after `T_max` time steps, and it's dependace on the inputs to the model.

- Finally I would like to look at the impact on the rate of innovation (and failurs) if we mutilate the network, for example by removing some nodes at random that represent  'high risk' nodes or 'bad actors'.  This will be a measure of the robustness of the innovation ecosystem to restrictions on communication. 

 
