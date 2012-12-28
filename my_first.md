Find Duplicate Files
========================================================

This is a simple script to search a directory tree for all files with duplicate content. it is based upon the python code presented by Raymond Hettinger in his PyCon AU 2011 keynote "What Makes Python Awesome". The slides are here: http://slidesha.re/WKkh9M . As an exercise, I decided to convert the code to R. 


**The Original Python Code**

```
# A bit of awesomeness in five minutes
# Search directory tree for all duplicate files  
import os, hashlib
hashmap = {}  # content signature -> list of filenames  
for path, dirs, files in os.walk('/Users/user/Dropbox/kaggle/r_projects/test_photo'):
  for filename in files:
		fullname = os.path.join(path, filename)
		with open(fullname) as f:
			d = f.read()         
		h = hashlib.md5(d).hexdigest()         
		filelist = hashmap.setdefault(h, [])         
		filelist.append(fullname)   
pprint.pprint(hashmap)
```
 
 which has the following expected output (given my test directory):
```
{'79123bbfa69a73b78cf9dfd8047f2bfd': 
['/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480 copy.JPG',
 '/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480.JPG'],
 '8428f6383f9591a01767c54057770989': 
 ['/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482 copy.JPG',
  '/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482.JPG',
  '/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482 copy.JPG',
  '/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482.JPG'],
 '8b25c2e6598c33aa1ca255fe1c14a775': 
 ['/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481 copy.JPG',
  '/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481.JPG',
  '/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3481.JPG']}
```                                      

**The R Code**

Step 1: Load the digest library so we can calculate [MD5](http://en.wikipedia.org/wiki/Md5) hash values. The MD5 hash is common method of checking data integrity. We'll be calculating the MD5 hash of each photo file to determine the uniqueness of the file contents (independent of file name and location).  

```r
library("digest")
```

The next code chunk  A list of photo files are recursively generated using the dir() function. Note the regex "JPG|AVI" parameter to isolate the files of interest.   

```r
test_dir = "/Users/user/Dropbox/kaggle/r_projects/test_photo"
filelist <- dir(test_dir, pattern = "JPG|AVI", recursive = TRUE, all.files = TRUE, 
    full.names = TRUE)
head(filelist)
```

```
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480.JPG"     
## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481 copy.JPG"
## [4] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481.JPG"     
## [5] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482 copy.JPG"
## [6] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482.JPG"
```

Now that we have the list of files, let's generate the md5 hash function to each file. In this case, I am limiting the MD5 calculation to the first 5000 bytes of the file to speed things up. :
 
 ```r
 md5s <- sapply(filelist, digest, file = TRUE, algo = "md5", length = 5000)
 duplicate_files = split(filelist, md5s)
 head(duplicate_files)
 ```
 
 ```
 ## $`56fd210390058f97ccba512db9b23b89`
 ## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480 copy.JPG"
 ## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480.JPG"     
 ## 
 ## $c142f7904e355be0c1f6d38211ed602f
 ## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482 copy.JPG"
 ## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482.JPG"     
 ## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482 copy.JPG"
 ## [4] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482.JPG"     
 ## 
 ## $e6ecbcc84eca1c044fcf8669db1882fa
 ## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481 copy.JPG"
 ## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481.JPG"     
 ## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3481.JPG"
 ```

That completes the code conversion. However, to make the results a little more useful, we can split the unique and duplicate files by the length of the lists. An MD5 hash with more than one filename indicates duplicate files: 

```r
z = duplicate_files
z2 = sapply(z, function(x) {
    length(x) > 1
})
z3 = split(z, z2)
head(z3$"TRUE")
```

```
## $`56fd210390058f97ccba512db9b23b89`
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480.JPG"     
## 
## $c142f7904e355be0c1f6d38211ed602f
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482.JPG"     
## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482 copy.JPG"
## [4] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482.JPG"     
## 
## $e6ecbcc84eca1c044fcf8669db1882fa
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481.JPG"     
## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3481.JPG"
```


**Notes on Vectorization**
A previous attempt utilized a "for" loop o create the list of file digests. But as Jeffery Breen said in his excellent presentation on  [grouping and summarizing data in r] (http://www.slideshare.net/jeffreybreen/grouping-summarizing-data-in-r)   
"Rule of Thumb: If you are using a loop in R you're probably doing something wrong."    

```r
fl = list()  #create and empty list to hold md5's and filenames
for (itm in filelist) {
    file_digest = digest(itm, file = TRUE, algo = "md5", length = 1000)
    fl[[file_digest]] = c(fl[[file_digest]], itm)
}
head(fl)
```

```
## $`5715b719723c5111b3a38a6ff8b7ca56`
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3480.JPG"     
## 
## $`24fd4d7d252ca66c8d7a88b539c55112`
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3481.JPG"     
## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3481.JPG"     
## 
## $`2a1d668c874dc856b9df0fbf3f2e81ec`
## [1] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482 copy.JPG"
## [2] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_a/IMG_3482.JPG"     
## [3] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482 copy.JPG"
## [4] "/Users/user/Dropbox/kaggle/r_projects/test_photo/folder_b/IMG_3482.JPG"
```

**Credits**: The stackoverflow user [nograpes] (http://stackoverflow.com/users/1086688/nograpes) and others in the stackoverflow community were very helpful with the elegant solution to the vectorization problem which I posted [here](http://stackoverflow.com/questions/14060423/how-to-vectorize-this-r-code-using-plyr-apply-or-similar)
