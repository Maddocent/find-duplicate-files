
library("digest")
# library("plyr")
# 
# library("hash")
# hashmap <-hash()

test_dir= "/Volumes/Public/book_k/photo_backup"
##test_dir = "/Users/user/Dropbox/kaggle/r_projects/test_photo"
filelist <- dir(test_dir, pattern = "JPG|AVI", recursive=TRUE, all.files =TRUE, full.names=TRUE)
head(filelist)

# h=ldply(filelist, digest, file=TRUE, algo="md5", length = 1000)

# to process the entire file, just remove the length parameter as shown here:
# h=ldply(results, digest, file=TRUE, algo="md5")

# h$filenames=filelist
# 
# file_duplicates = duplicated(h[,1]) 
# file_dupes = h[file_duplicates,]    #use logical vector to extract the list of duplicates
# head(file_dupes,50)
#the non-duplicates
# h[!file_duplicates,]

#The unique function can also be used to extract unique elements

# h_unique = unique(h[,1])

#this works
# fl = list() #create and empty list to hold md5's and filenames
# for (itm in filelist) {
#   file_digest = digest(itm, file=TRUE, algo="md5", length = 1000)
#   fl[[file_digest]]= c(fl[[file_digest]],itm)
# }
# head(fl)

# a more concise, vectorized solution 
# http://stackoverflow.com/questions/14060423/how-to-vectorize-this-r-code-using-plyr-apply-or-similar
md5s<-sapply(filelist,digest,file=TRUE,algo="md5", length = 5000)
duplicate_files = split(filelist,md5s)

# now let's divide the list into duplicates ( length > 1) and uniques ( lenght - 1)
z = duplicate_files
z2 = sapply(z,function (x){length(x)>1})
z3 = split(z,z2)