EXAMPLES := 0-intuition 1-inner-double 2-inner-single 3-inner-single

control:
	sh 	  $(EXAMPLES)
	sh -i $(EXAMPLES)
	bash  $(EXAMPLES)

bashbug:
	bash -i $(EXAMPLES)

root-shell:
	./4-curious

env:
	env -i PATH="$$PATH" TERM="$$TERM" bash --norc --noprofile -i
