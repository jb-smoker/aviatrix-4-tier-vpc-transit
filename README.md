aviatrix-4-tier-vpc-transit
===============

Terraform for a 3 vpc Aviatrix transit network in aws.

# Overview:
* Creates a 3 vpc Aviatrix transit network in aws. 

# Caveat:
* This is just example terraform and cannot be run all at once due to dependences. The VPCs need to be created first, followed by the Aviatrix control plane, then finally the transit network.
