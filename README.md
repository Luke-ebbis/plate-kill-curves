# martin-data

## Data entry

The data for this `R` script should be in the following structure:

```
├── data
│   ├── test_experiment
│   │   ├── 2023-11-16-resaruzin.csv
│   │   ├── 23-11-16 16-16-12 Resazurin_Samples.csv
│   │   ├── 23-11-16 16-16-12 Resazurin_Treatments.csv
│   │   └── metadata.CSV
│   ├── test_experiment_1
│   │   ├── 2023-11-16-resaruzin.csv
│   │   ├── 23-11-16 16-16-12 Resazurin_Samples.csv
│   │   ├── 23-11-16 16-16-12 Resazurin_Treatments.csv
│   │   └── metadata.CSV
│   └── test_experiment_3
│       ├── 2023-11-16-resaruzin.csv
│       ├── 23-11-16 16-16-12 Resazurin_Samples.csv
│       ├── 23-11-16 16-16-12 Resazurin_Treatments.csv
│       └── metadata.CSV
```

Each plate readout is in its own folder. For each plate readout there are 4 files.

* `metadata.csv`: Here experimental treatments and measurement details of the assay are described.
* `samples`: Here the layout of where each sample is is described.
* `treatment`: Here the treatment variable is displayed.
* `values`: Here the output of the plate reader is kept.

It is important to *not* introduce any spaces in the cells.

The layout of the treatment and sample plates is similar, both have the header 
being the columns and the rows being in the first column.

```csv
,1,2,3,4,5,6,7,8,9,10,11,12
A,0,200,175,150,125,100,75,50,25,10,5,0
B,0,200,175,150,125,100,75,50,25,10,5,0
C,0,200,175,150,125,100,75,50,25,10,5,0
D,0,200,175,150,125,100,75,50,25,10,5,0
E,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
F,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
G,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
H,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
```


The measurement file is slightly different:

```csv
User: Phyto 2021,Path: C:\Program Files (x86)\BMG\CLARIOstar\Phyto 2021\Data,Test run no.: 554,,,,,,,,,,
Test name: Resazurin,Date: 9/20/2023,Time: 8:33:05 PM,,,,,,,,,,
,,,,,,,,,,,,
Fluorescence (FI),,,,,,,,,,,,
,,,,,,,,,,,,
Well Scan: Average (570-8/615-8),,,,,,,,,,,,
,,,,,,,,,,,,
,1,2,3,4,5,6,7,8,9,10,11,12
A,1873.1,1532.4,1529.9,1549.9,1570.4,1643.6,1801.6,2249.4,2796.3,2821.3,2894.9,2718.7
B,1814,1431.7,1412.4,1414.7,1440.1,1469,1593.7,1947.8,2444.8,2836.6,2868.3,2684.1
C,1856.9,1454.3,1445,1467.7,1478.7,1508,1622.8,1947.6,2454.8,2883.9,2954.4,2822.6
D,1864.2,1485,1464.7,1484.8,1489.3,1523.4,1634.3,1966.1,2479.3,2779.2,2875.4,2805.6
E,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
F,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
G,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
H,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty,empty
```

## Usage

You'll need the [`pixi`](https://prefix.dev/) package manager, this is compatible for windows and linux. To view the help page:

```
pixi run help
```

