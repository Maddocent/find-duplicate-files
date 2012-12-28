
library("digest")
test_dir= "/Volumes/Public/book_k/photo_backup"
filelist <- dir(test_dir, pattern = "JPG|AVI", recursive=TRUE, all.files =TRUE, full.names=TRUE)

# a concise, vectorized solution 
# http://stackoverflow.com/questions/14060423/how-to-vectorize-this-r-code-using-plyr-apply-or-similar
md5s<-sapply(filelist,digest,file=TRUE,algo="md5", length = 5000)
duplicate_files = split(filelist,md5s)

# now let's divide the list into duplicates ( length > 1) and uniques ( length - 1)
z = duplicate_files
z2 = sapply(z,function (x){length(x)>1})
z3 = split(z,z2)
head(z3$"TRUE")