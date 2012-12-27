Find Duplicate Files
========================================================

This is a simple script to search a directory tree for all files with duplicate content. it is based upon the python keynote here (TBD)

Step 1: Load the digest library so we calculate MD5 hash values. Load plyr for handling the collections of filenames.

```r
library("digest")
library("plyr")
```


step 2, create an empty hash to save the results to.


```r
library("hash")
```

```
## hash-2.2.4 provided by Decision Patterns
```

```r
hashmap <- hash()
```


step 3: convert the following python code to english description + r code:
for path, dirs, files, in os.walk('/Volumes/Public/book_k'):
   for filename in files:
		 fullname = os.path.join(path,filename)
		 d = open(fullname).read()
		 h = hashlib.md5(d).hexdigest()
		 filelist = hashmap.setdefault(h, [])
         filelist.append(fullname)
         
this chunk below will list the files recursively . Not sure if this enough. I think I really want to "walk" a directory instead. note the regex "JPG|AVI" to isolate the files of interest.   

```r
## test_dir= '/Volumes/Public/book_k/photo_backup/all2008'
test_dir = "/Users/user/Dropbox/kaggle/r_projects/test_photo"
results <- dir(test_dir, pattern = "JPG|AVI", recursive = TRUE, all.files = TRUE, 
    full.names = TRUE)
head(results)
```

```
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480.JPG"     
## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481 copy.JPG"
## [4] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481.JPG"     
## [5] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482 copy.JPG"
## [6] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482.JPG"
```

 now that I have the list of files, generate the md5 hash function to each file. In this case, I am limiting the MD5 calculation to the first 1000 bytes of the file to speed things up. :
 
 ```r
 h = ldply(results, digest, file = TRUE, algo = "md5", length = 1000)
 # to process the entire file, just remove the length parameter:
 # h=ldply(results, digest, file=TRUE, algo='md5')
 ```

now lets add the filenames to the results dataframe


```r
h[, 2] = results
```


A total of 9 files will be processed for this test case:

To find the duplicates, simply use the duplicated function on the first column ( which contains the md5 hash for the file)

```r
file_duplicates = duplicated(h[, 1])
file_dupes = h[file_duplicates, ]  #use logical vector to extract the list of duplicates
head(file_dupes, 50)
```

```
##                                 V1
## 2 5715b719723c5111b3a38a6ff8b7ca56
## 4 24fd4d7d252ca66c8d7a88b539c55112
## 6 2a1d668c874dc856b9df0fbf3f2e81ec
## 7 24fd4d7d252ca66c8d7a88b539c55112
## 8 2a1d668c874dc856b9df0fbf3f2e81ec
## 9 2a1d668c874dc856b9df0fbf3f2e81ec
##                                                                            V2
## 2      /Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480.JPG
## 4      /Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481.JPG
## 6      /Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482.JPG
## 7      /Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3481.JPG
## 8 /Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482 copy.JPG
## 9      /Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482.JPG
```


The unique function can also be used to extract unique elements

```r
h_unique = unique(h[, 1])
```

Mt test case results in 3 unique elements.
