#include "globals.h"
#include "flags.h"
#include "reader.h"
#include "fluxmap.h"
#include "decoders/decoders.h"
#include "amiga/amiga.h"
#include "sector.h"
#include "sectorset.h"
#include "record.h"
#include "fmt/format.h"
#include <fstream>

static FlagGroup flags { &readerFlags };

int mainReadAmiga(int argc, const char* argv[])
{
	setReaderDefaultSource(":t=0-79:s=0-1");
	setReaderDefaultOutput("amiga.adf:c=80:h=2:s=11:b=512");
    setReaderRevolutions(2);
    flags.parseFlags(argc, argv);

	AmigaDecoder decoder;
	readDiskCommand(decoder);

    return 0;
}

