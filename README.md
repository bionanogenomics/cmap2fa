# Tool for Transforming CMAP to FASTA Format

### Overview 
cmap2fa.pl is a tool for converting a BioNano multi-color CMAP file of nicking enzyme label positions to an NGS FASTA file of nucleotides sequences. The tool translates each label position to an enzyme-specific sequence (as in its forward strand format), and fills every interval of two labels with “N”s.   

###Usage
perl cmap2fa.pl [options] <Args>

Options:
* -h	This help message
* -i	Input CMAP file (Required)
* -o	Output folder (Default: the same as the input file)

NOTE:	The input CMAP index is 1-based.

### Limitations
Since the input CMAP does not have strand information, the tool translates each label in its forward strand format.  This may not represent the original NGS sequence as the labels in the input CMAP may be generated from either orientation of the enzyme sequences.
For hybrid scaffold, however, this should not be an issue as the generated FASTA file will eventually be converted back to CMAP format which contains only label positions.

### License
We offer this tool for open source use under the [MIT Software License](https://opensource.org/licenses/MIT). 
