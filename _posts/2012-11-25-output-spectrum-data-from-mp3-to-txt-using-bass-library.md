---
layout: post
title: Output Spectrum Data From MP3 to TXT Using BASS Library
date: '2012-11-25'
description: Using the BASS library to output spectrum data for an mp3 to an ascii file
categories: [other]
tags: [BASS, mp3, spectrum, output]
---

In order to make the [fountain video](http://vimeo.com/53651625) I needed to take an mp3 file and get its spectrum data to an ascii file. This data would then be used as the input to the simulation.

The code below will take an "INPUT.mp3" and output to "OUTPUT.txt" the rate at which the data is collected (fps) can be controlled along with the resolution of the data (BANDS). 

The code was written using the writewav.c and spectrum.c examples in the [BASS sdk](http://www.un4seen.com/bass.html). 
The library is free for non-commercial use and is availible for Windows, Mac OS, Linux, Win64, WinCE, iOS, Android, and ARM


{% highlight c++ %}
//Written by Hammad Mazhar
//2012 hamelot.co.uk
//

&#35;include &lt;stdlib.h>
&#35;include &lt;stdio.h>
&#35;include "bass.h"

&#35;ifdef _WIN32 // Windows
&#35;include &lt;conio.h>
&#35;else // OSX
&#35;include &lt;sys/types.h>
&#35;include &lt;sys/time.h>
&#35;include &lt;termios.h>
&#35;include &lt;string.h>
&#35;endif

FILE *output_data;
char *output_name = "OUTPUT.txt";
char *input_name = "INPUT.mp3";
double fps = 60;    //how many samples should be taken per second
int BANDS = 120;    //how many "bins" to devide the spectum in (also the number of columns on each row of output)

void main(int argc, char **argv)
{
    DWORD chan, p;
	QWORD pos;
	output_data = fopen(output_name, "w");
	printf("BASS Spectrum writer example : MOD/MPx/OGG -> FILE.TXT\n-------------------------------------------------\n");
	BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, 0);    // no audio output, therefore no update period needed
	BASS_Init(0, 44100, 0, 0, NULL);                // null device, 44100hz, stereo, 16 bits
	chan = BASS_StreamCreateFile(FALSE, input_name, 0, 0, BASS_STREAM_DECODE);  //streaming the file
	pos = BASS_ChannelGetLength(chan, BASS_POS_BYTE);
	printf("streaming file [%llu bytes]", pos);
	p = (DWORD) BASS_ChannelBytes2Seconds(chan, pos);  //length of file in seconds
	printf(" %u:%02u\n", p / 60, p % 60);
	float time = 0;

	while (BASS_ChannelIsActive(chan)) {
		long byte_pos = BASS_ChannelSeconds2Bytes(chan, time);
		BASS_ChannelSetPosition(chan, byte_pos, BASS_POS_BYTE);
		float fft[1024];
		int b0 = 0;
		BASS_ChannelGetData(chan, fft, BASS_DATA_FFT2048);  //get the fft data, in this case there are 2048 samples

		//binning the fft, modified from bass spectum.c example in sdk.
		for (int i = 0; i < BANDS; i++) {
			float peak = 0;
			int b1 = pow(2, i * 10.0 / (BANDS - 1)); //determine size of the bin

			if (b1 > 1023) {b1 = 1023;} //upper bound on bin size

			if (b1 <= b0) {b1 = b0 + 1;} //make sure atleast one bin is used

			//loop over every bin
			for (; b0 < b1; b0++) {
				if (peak < fft[1 + b0]) {peak = fft[1 + b0];}
			}
			//write each column to file
			fprintf(output_data, "%f,", sqrt(peak));
		}
		//endline after every row
		fprintf(output_data, "\n");
		pos = BASS_ChannelGetPosition(chan, BASS_POS_BYTE);
		p = (DWORD) BASS_ChannelBytes2Seconds(chan, pos);
		printf(" %u:%02u\n", p / 60, p % 60);  //print current time
		time += 1 / fps;   //increment time
	}

	printf("DONE!");
	fclose(output_data);
	BASS_Free();
}
{% endhighlight %}
