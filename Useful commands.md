**How to Find Biggest Files and Directories in Linux?**
```bash
du -a /home | sort -n -r | head -n 5 #Run the following command to find out the top biggest directories under /home partition.
du -hs * | sort -rh | head -5 #display the above result in a human-readable format.
du -Sh | sort -rh | head -5 #To display the largest folders/files including the sub-directories
du -h /home/user/Desktop | grep '^\s*[0-9\.]\+G' #t to see all files that are above a certain size. The most effective way to do that is by using this command
du -h /home/user/Desktop/ --exclude="*.txt" #The last combination is useful when you need to exclude a particular file format from the search results.
unzip /path/to/file.zip -d temp_for_zip_extract #extract a zip file to a specific folder
curl -vvvvvvv https://hooks.slack.com #curl tls and cert of destination address
curl -v <web_url>

```
