#takes in two lists of genes and their length and expression value (format: geneName \t length \t expression)
args = commandArgs(TRUE)

primary.genes = read.table(args[1], sep="\t", row.names=1)
other.gene.set = read.table(args[2], sep="\t", row.names=1)
colnames(primary.genes) = c("Length","Expr")
colnames(other.gene.set) = c("Length","Expr")

final.matched.genes = c()

for(i in 1:(nrow(primary.genes))){
	cur.gene.name = rownames(primary.genes[i,])
	cur.gene.length = primary.genes[i,1]
	cur.gene.expr = primary.genes[i,2]
	
	other.gene.set.orderedByExprDiff = other.gene.set[order(abs(other.gene.set$Expr - cur.gene.expr)),]
	
	gene.with.match = other.gene.set.orderedByExprDiff[other.gene.set.orderedByExprDiff$Length > (cur.gene.length-cur.gene.length*0.05) & other.gene.set.orderedByExprDiff$Length < (cur.gene.length+cur.gene.length*0.05),][1,]
	
	final.matched.genes = rbind(final.matched.genes, gene.with.match)
	
	other.gene.set = other.gene.set[!rownames(other.gene.set) %in% rownames(gene.with.match),]
}

write.table(final.matched.genes, file=args[3], sep="\t", quote=F, row.names=T, col.names=NA)
