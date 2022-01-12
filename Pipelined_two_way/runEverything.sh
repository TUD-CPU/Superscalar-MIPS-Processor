
for d in *;
do
    if [ -d "${d}" ];
    then
        if [ $d != "Test" -a $d != "Assembler" -a $d != "Documentation" -a $d != "Execution_Time_Test" ]
        then
            cd $d
            for filename in *.vhdl;
            do
                if [[ "$filename" != *"_tb"* ]];
                then
                    cd ..
                    cp -R $d/$filename Test/
                fi
            done
        fi
    fi
done


cp -R Execution_Time_Test/mips_pipelined_tb.vhdl Test/

cd Assembler

g++ Assembler.cpp -o Assembler.out
./Assembler.out "../$1" ../Test/instr_mem.vhdl
cd ..

cd Test

./compileAll.sh
echo
./compile.sh mips_pipelined_tb.vhdl