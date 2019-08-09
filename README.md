Converting bedGraph to bigWig
================
Carson Callahan
August 8, 2019

Intro
-----

UPDATE: I have written a bash script that will automate this process. See the bottom of this post for details.

I recently needed to download some data from GEO/ENCODE to see if a handful of TFs had ChIP-grade antibodies that actually work well. The idea was pretty simple: download some bigWigs, throw them onto IGV, and see how good the peaks looked. This worked out well enough for samples that had data from the ENCODE project, where bigWigs seem to be preferred. However, for one of my TFs of interest, I could only find data by searching GEO directly, and the single study with ChIP only provided bedGraph files. Not wanting to download raw fastqs just to get bigWigs, I started searching for ways to convert the format. For reference, here are the links to the GEO data (it's replicates of the same ChIP): [rep1](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM2902699) [rep2](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM2902700)

UCSC has some detailed information about the [bedGraph format](https://genome.ucsc.edu/goldenPath/help/bedgraph.html) and about the [bigWig format](https://genome.ucsc.edu/goldenpath/help/bigWig.html). Simply put, bedGraphs contain the same coordinate information as a bed file, but also a 4th column of values that represent the seqeuncing coverage in that region. On the other hand, bigWigs are indexed binaries of this information. More reading can be found [on Biostars.](https://www.biostars.org/p/113452/)

Converting the files
--------------------

Ok, so, our task is pretty straightforward: convert the bedGraphs to bigWigs so IGV will like them and we can make things a bit more snappy. To actually perfrom the conversion, we're going to be using the tool available from UCSC. They provided the tool's binaries, so you'll have to download the one specific to your operating system. Link [here.](http://hgdownload.soe.ucsc.edu/admin/exe/) The tool we're looking for is simply called "bedGraphToBigWig."

In any case, it's not a bad idea to make sure your bedGraph is lexicographically sorted - I've found this isn't super common, and our conversion tool requires it. Here's a one-liner in bash to do this (replace the files names with your own):

``` bash
LC_COLLATE=C sort -k1,1 -k2,2n file_name.bedGraph > file_name_sorted.bedGraph
```

Next, we'll need to clean up the file a bit to match the proper bedGraph format - our sorting has messed with the header. First step, just add the header back:

``` bash
sed -i '1 i\track\ttype=bedGraph' file_name.bedGraph
```

One note here: if you're on MacOS, you'll need to change the line slightly - just type " -i '' " instead of " -i " alone.

Next, we need to chop off some unneeded lines from the file:

``` bash
head -n -1 file_name.bedGraph > tmp.bedGraph ; mv tmp.bedGraph file_name.bedGraph
```

This code will remove the last line and save that as a temporary file, then rename the temporary file to whatever you like. Renaming the temporary file to the initial file name will in effect just delete the last line. On Mac, you may need to do the following steps for this to work: (1) brew install coreutils (2) use "ghead" instead of "head".

Now that we have our bedGraph file all prepared, we can use the tool we downloaded earlier. To make sure this goes smoothly, place the bedGraphToBigWig executable in the same directoy as your bedGraph files.

Next, we have to make the executable file *actually* executable:

``` bash
chmod u+x bedGraphToBigWig
```

Now, run the following code to convert an individual file:

``` bash
./bedGraphToBigWig file_name.bedGraph http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes file_name.bigWig
```

The hyperlink included in the code simply takes the chromosome sizes from the UCSC hg19 repository. You can replace this with a local copy of the file if you have one.

Now you just repeat this for each bedGraph you have.

Conclusion
----------

That basically does it. You should now have all your bedGraphs converted to bigWigs. Just drag them onto IGV, and you should be good to go. This process helps you make the files more portable (for example, one of my files went from &gt;650MB to just over 120MB) and circumvents some issues with the UCSC browser itself (i.e., it only takes files up to 500MB).

Running the bash script to convert all files
--------------------------------------------

The bash script can be found in this repository. It's called `ConvertBedGraphsToBigWigs.sh`. It assumes a few things:

-   You have downloaded the correct bedGraphToBigWig binary for your OS and have placed it in the same directory as your bedGraph files
-   The shell script itself is also placed in this directory
-   The bedGraphs aren't compressed (i.e., they need to be unzipped if originially in .gz format, etc.)

Before you run the file, there are two additional lines you need to run. First, navigate to the directory containing your bedGraph files, the binary downloaded from UCSC, and the shell script. Now run the following lines

``` bash
chmod u+x ConvertBedGraphsToBigWigs.sh bedGraphToBigWig
```

This will ensure both files are executable. Next, to run the shell script, simply enter the following into the terminal and press enter:

``` bash
bash ConvertBedGraphsToBigWigs.sh
```

The script will the begin converting all of the bedGraph files in your directory into bigWigs. You will still have the bedGraphs in case you want/need them for some other analysis. The script will also print progress messages in the terminal window, so you can check how many bedGraph files you will be converting and which file the script is working on. The script will also print a message in the terminal upon converting all the bedGraphs, so that you know when everything is done.
