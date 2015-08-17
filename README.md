# Text-Mining-Final-Project

Code to that created the [Presidential Documents LDA](chetanmishra.com) (to access it, click "Presidential Documents LDA" under the Deliverable dropdown).

## Technical Details

Technical details with equations rendered properly are available if you follow the directions above. The technical details (with equations written in LaTeX form) are available below.

*Powerpoint presentation available [here](https://github.com/cmishra/Text-Mining-Final-Project/blob/master/presentation.pptx).*

**Data set:** [Compiled Presidential Documents](http://www.gpo.gov/fdsys/browse/collection.action?collectionCode=CPD)

**Purpose:** How can we quantitatively measure what the administration was focused on and how the focus changed over time?

**Methodology:** Use Latent Dirichlet Allocation (LDA) to find a set of topics on the data. Identify the number of topics using a greedy heuristic that maximizes Log-Likelihood.

**Metric:** Recall that within LDA, $\theta_d$ is the distribution of topics in document $d$. During a unit of time, the set of public interactions, statements, and documents released are $i$. Of a topic $t$, the relevance score $S_{t,i}=\sum_{d\in i)\phi_{d,t}$
