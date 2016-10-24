OPT   = -O3
FLAGS = -Wall -Wno-deprecated-declarations -D_POSIX_C_SOURCE=200112L $(OPT) -pthread 
GPP   = g++ -march=native -m64 -std=c++11 $(FLAGS)

all:	equi equi1 verify test spark test1445

equi:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DATOMIC equi_miner.cpp blake/blake2b.cpp -o equi

equi1:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) equi_miner.cpp blake/blake2b.cpp -o equi1

equi1g:	equi.h equi_miner.h equi_miner.cpp Makefile
	g++ -g -std=c++11 -DLOGSPARK -DSPARKSCALE=11 equi_miner.cpp blake/blake2b.cpp -pthread -o equi1g

equi1445:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DRESTBITS=4 -DWN=144 -DWK=5 equi_miner.cpp blake/blake2b.cpp -o equi1445

dev:	equi.h dev_miner.h dev_miner.cpp blake2b/asm/zcblake2_avx2.o Makefile
	$(GPP) -DATOMIC dev_miner.cpp blake/blake2b.cpp blake2b/asm/zcblake2_avx2.o -o dev

dev1:	equi.h dev_miner.h dev_miner.cpp blake2b/asm/zcblake2_avx2.o Makefile
	$(GPP) dev_miner.cpp blake/blake2b.cpp blake2b/asm/zcblake2_avx2.o -o dev1

hash1:	equi.h dev_miner.h dev_miner.cpp blake2b/asm/zcblake2_avx2.o Makefile
	$(GPP) -DHASHONLY dev_miner.cpp blake/blake2b.cpp blake2b/asm/zcblake2_avx2.o -o hash1

equidev:	equi.h equi_dev_miner.h equi_dev_miner.cpp Makefile
	$(GPP) -DATOMIC equi_dev_miner.cpp blake/blake2b.cpp -o equidev

equidev1:	equi.h equi_dev_miner.h equi_dev_miner.cpp Makefile
	$(GPP) equi_dev_miner.cpp blake/blake2b.cpp -o equidev1

eqcuda:	equi_miner.cu equi.h blake2b.cu Makefile
	nvcc -DXINTREE -DUNROLL -arch sm_35 equi_miner.cu blake/blake2b.cpp -o eqcuda

devcuda:	dev_miner.cu equi.h blake2b.cu Makefile
	nvcc -DXINTREE -DUNROLL -arch sm_35 dev_miner.cu blake/blake2b.cpp -o devcuda

eqcuda1445:	equi_miner.cu equi.h blake2b.cu Makefile
	nvcc -DWN=144 -DWK=5 -arch sm_35 equi_miner.cu blake/blake2b.cpp -o eqcuda1445

verify:	equi.h equi.c Makefile
	g++ -g equi.c blake/blake2b.cpp -o verify

verify1445:	equi.h equi.c Makefile
	g++ -DRESTBITS=4 -DWN=144 -DWK=5 -g equi.c blake/blake2b.cpp -o verify1445

bench:	equi1
	time ./equi1 -r 10

test:	equi1 verify Makefile
	time ./equi1 -h "" -n 0 -t 1 -s | grep ^Sol | ./verify -h "" -n 0

test1445:	equi1445 verify1445 Makefile
	time ./equi1445 -h "" -n 0 -t 1 -s | grep ^Sol | ./verify1445 -h "" -n 0

spark:	equi1g
	time ./equi1g

blake2b/asm/zcblake2_avx1.o:
	make -C blake2b

blake2b/asm/zcblake2_avx2.o:
	make -C blake2b

clean:	
	make -C blake2b clean && rm -f dev dev1 equi equi1 equi1g equi1445 eqcuda eqcuda1445 verify
