#include<iostream>
#include<fstream>
#include <bitset>
#include <string>
#include <sstream>
#include<regex>
#include<unordered_map>


enum Instr {rtype, lw, sw, beq, addi, lui, xori, j, idle};
enum RType {rAdd, rSub, rAnd, rOr, rNor, rXor, rSll, rSrl, rSra, rSlt};

std::unordered_map<std::string, int> labels;

std::ofstream out;
int memloc;

void assembleFile(std::string input, std::string output, int euCount);
void handleRtype(std::string line, int lineNum);
void handleLw(std::string line, int lineNum);
void handleSw(std::string line, int lineNum);
void handleBeq(std::string line, int lineNum);
void handleAddi(std::string line, int lineNum);
void handleLui(std::string line, int lineNum);
void handleXori(std::string line, int lineNum);
void handleNot(std::string line, int lineNum);
void handleJ(std::string line, int lineNum);
void handleIdle(std::string line, int lineNum);
void handleExit(std::string line, int lineNum);
std::string rtypeInstr(int r1, int r2, int r3, int shamt, RType type);
std::string lwInstr(int r1, int offset, int r2);
std::string swInstr(int r1, int offset, int r2);
std::string beqInstr(int r1, int r2, int offset);
std::string addiInstr(int r1, int r2, int offset);
std::string luiInstr(int r1, int imm);
std::string xoriInstr(int r1, int r2, int imm);
std::string jInstr(int address);
std::string intToBitString(int i, int length);

int main(int argc, char **argv){
    std::string inPath;
    std::string outPath;
    int euCount = 2;
    if(argc == 2){
        inPath = argv[1];
        outPath = "out.txt";
    } else if(argc == 3){
        inPath = argv[1];
        outPath = argv[2];
    } else if(argc == 4){
	inPath = argv[1];
        outPath = argv[2];
	try{
	    euCount = std::stoi(argv[3]);
        }
	catch(...){
	    std::cout << "Parameter 4 (execution unit count) is not a number!" << std::endl;
	    exit(1);
	}
        
    }
    assembleFile(inPath, outPath, euCount);

    return 0;
}

void assembleFile(std::string input, std::string output, int euCount){
    std::ifstream in1(input);
    std::ifstream in2(input);

    out.open(output);

    memloc = 0;
    int lineNum = 1;
    std::string line;


    if(in1.is_open()){
        while (std::getline(in1, line)){
            if(line[0] == '.'){
                if(line[line.size()-1] == 13){
                    line = line.substr(0, line.size()-1);
                }
                labels[line] = lineNum;
            } else {
                ++lineNum;
            }
        }
        
    }

    in1.close();


    lineNum = 0;

    if(in2.is_open()){

        out << "library ieee;"
                "use ieee.std_logic_1164.all;\n"
                "use ieee.numeric_std.all;\n"
                "\n"
                "entity instr_mem is\n"
                "\tport (\n";

	for(int i = 1; i <= euCount; i++){
		out << "\t\tpc" << i << ": in std_logic_vector(31 downto 0);\n";
	}

	for(int i = 1; i <= euCount; i++){
		out << "\t\tinstr" << i << ": out std_logic_vector(31 downto 0)";
		if(i < euCount){
			out << ";";
		}
		out << "\n";
	}
        out << "\t);\n"
                "end;\n"
                "\n"
                "architecture behavior of instr_mem is\n"
                "\ttype ramtype is array (255 downto 0) of std_logic_vector(31 downto 0);\n"
                "\tsignal mem: ramtype;\n"
                "begin\n\n";


        while (std::getline(in2, line)){

            bool comment = false;

            if(line[line.size()-1] == 13){
                line = line.substr(0, line.size()-1);
            }

            if(line.size() > 0){
                if(std::regex_match(line, std::regex("(\\s)*#.*"))){
                    out << "--";
                    int j=0;
                    while (line[j]!='#'){
                        ++j;
                    }
                    
                    line = line.substr(j+1, line.size());

                    comment = true;
                } else if(line[0] == '.'){
                    out << "--\t" << line << std::endl;
                }
                if(line[0] != '.' && std::regex_match(line, std::regex("(\\s)*.+"))){
                    int k = 0;
                    std::string s;
                    while(k < line.size() && line[k]!='#'){
                        s+=line[k];
                        ++k;
                    }
                    line = s;
                    ++lineNum;
                    int i=0;
                    while (line[i] == ' ' || line[i] == '\t'){
                        ++i;
                    }
                    line = line.substr(i, line.size());
                    if(line.rfind("lw", 0) == 0){
                        handleLw(line, lineNum);
                    } else if(line.rfind("sw", 0) == 0){
                        handleSw(line, lineNum);
                    } else if(line.rfind("beq", 0) == 0){
                        handleBeq(line, lineNum);
                    } else if(line.rfind("addi", 0) == 0){
                        handleAddi(line, lineNum);
                    } else if(line.rfind("lui", 0) == 0){
                        handleLui(line, lineNum);
                    } else if(line.rfind("xori", 0) == 0){
                        handleXori(line, lineNum);
                    } else if(line.rfind("not", 0) == 0){
                        handleNot(line, lineNum);
                    } else if(line.rfind("j", 0) == 0){
                        handleJ(line, lineNum);
                    } else if(line.rfind("idle", 0) == 0){
                        handleIdle(line, lineNum);
                    } else if(line.rfind("exit", 0) == 0){
                        handleExit(line, lineNum);
                    } else {
                        handleRtype(line, lineNum);
                    }
                }
            }

            
            if(!comment && line[0]!= '.'){
                ++memloc;
            }
        }
        
        out <<  "\n\tprocess(";

	for(int i = 1; i <= euCount; i++){
		out << "pc" << i;
		if(i < euCount) out << ", ";
	}

	out << ") begin\n";
	
	for(int i = 1; i <= euCount; i++){
		out << "\t\tinstr" << i << " <= mem(to_integer(unsigned(pc" << i << "(31 downto 2))));\n";
	}

        out << "\n"
                "\tend process;\n"
                "end;\n";

    }

    in2.close();

    out.close();
}

void handleRtype(std::string line, int lineNum){
    RType r;
    int r1 = 0;
    int r2 = 0;
    int r3 = 0;
    int shamt = 0;
    std::stringstream ss(line);
    std::string entry;
    for(int i=0; i<4; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 0:
                if(entry.compare("add") == 0){
                    r = rAdd;
                } else if(entry.compare("sub") == 0){
                    r = rSub;
                } else if(entry.compare("and") == 0){
                    r = rAnd;
                } else if(entry.compare("or") == 0){
                    r = rOr;
                } else if(entry.compare("xor") == 0){
                    r = rXor;
                } else if(entry.compare("nor") == 0){
                    r = rNor;
                } else if(entry.compare("sll") == 0){
                    r = rSll;
                } else if(entry.compare("srl") == 0){
                    r = rSrl;
                } else if(entry.compare("sra") == 0){
                    r = rSra;
                } else if(entry.compare("slt") == 0){
                    r = rSlt;
                }
                break;

            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                if(entry[0] == '$'){
                    r2 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 3:
                if(entry[0] == '$'){
                    r3 = std::stoi(entry.substr(1, entry.size()));
		    shamt = 0;
                }
		else if(r == rSll || r == rSrl || r == rSra){
		    try{
                   	 shamt = std::stoi(entry);
			 r3 = 0;
                    }
                    catch(...){
                        std::cout << "Error in line " << lineNum << "! Unexpected offset." << std::endl;
                    }
		}else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }

    out << "\tmem(" << memloc << ")\t<= \"" << rtypeInstr(r1, r2, r3, shamt, r) << "\";\t--" << line << std::endl;
}

void handleLw(std::string line, int lineNum){
    int r1, r2, offset;
    std::string off, reg;
    int j = 0;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("lw") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<3; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                if(std::regex_match(entry, std::regex("[0-9]+\\(\\$[0-9]+\\)"))){

                    while (entry[j] != '('){
                        off+=entry[j];
                        ++j;
                    }
                    j+=2;
                    while (entry[j] != ')'){
                        reg+=entry[j];
                        ++j;
                    }
                    offset=std::stoi(off);
                    r2=std::stoi(reg);


                } else {
                    std::cout << "Error in line " << lineNum << "! Syntax incorrect." << std::endl;
                    exit(1);
                }
                
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }

    out << "\tmem(" << memloc << ")\t<= \"" << lwInstr(r1, offset, r2) << "\";\t--" << line << std::endl;
}

void handleSw(std::string line, int lineNum){
    int r1, r2, offset;
    std::string off, reg;
    int j = 0;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("sw") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<3; ++i){
        if(std::getline(ss, entry, ' ')){
            switch (i){
            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                if(std::regex_match(entry, std::regex("[0-9]+\\(\\$[0-9]+\\)"))){

                    while (entry[j] != '('){
                        off+=entry[j];
                        ++j;
                    }
                    j+=2;

                    while (entry[j] != ')'){
                        reg+=entry[j];
                        ++j;
                    }
                    offset=std::stoi(off);
                    r2=std::stoi(reg);


                } else {
                    std::cout << "Error in line " << lineNum << "! Syntax incorrect." << std::endl;
                    exit(1);
                }
                
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }

    out << "\tmem(" << memloc << ")\t<= \"" << swInstr(r1, offset, r2) << "\";\t--" << line << std::endl;
}

void handleBeq(std::string line, int lineNum){
    int r1, r2, offset;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("beq") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<4; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                if(entry[0] == '$'){
                    r2 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 3:
                if(entry[0] == '.'){
                    if(labels.find(entry) != labels.end()){
                        offset = labels[entry] - lineNum - 1;
                    } else {
                        std::cout << "Error in line " << lineNum << "! Label does not exist!" << std::endl;
                        exit(1);
                    }
                } else {
                    try{
                        offset = std::stoi(entry);
                    }
                    catch(...){
                        std::cout << "Error in line " << lineNum << "! Unexpected offset." << std::endl;
                        exit(1);
                    }
                }
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }

    out << "\tmem(" << memloc << ")\t<= \"" << beqInstr(r1, r2, offset) << "\";\t--" << line << std::endl;
}

void handleAddi(std::string line, int lineNum){
    int r1, r2, offset;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("addi") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<4; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                if(entry[0] == '$'){
                    r2 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 3:
                try{
                    offset = std::stoi(entry);
                }
                catch(...){
                    std::cout << "Error in line " << lineNum << "! Unexpected offset." << std::endl;
                }
                
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }
    out << "\tmem(" << memloc << ")\t<= \"" << addiInstr(r1, r2, offset) << "\";\t--" << line << std::endl;
}

void handleXori(std::string line, int lineNum){
    int r1, r2, offset;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("xori") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<4; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                if(entry[0] == '$'){
                    r2 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 3:
                try{
                    offset = std::stoi(entry);
                }
                catch(...){
                    std::cout << "Error in line " << lineNum << "! Unexpected offset." << std::endl;
                }
                
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << line << "(line " << lineNum << ")! Too few operands." << std::endl;
            exit(1);
        }
    }
    out << "\tmem(" << memloc << ")\t<= \"" << xoriInstr(r1, r2, offset) << "\";\t--" << line << std::endl;
}


void handleNot(std::string line, int lineNum){
    int r1, r2;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("not") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<3; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                if(entry[0] == '$'){
                    r2 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }
    out << "\tmem(" << memloc << ")\t<= \"" << rtypeInstr(r1, r2, r2, 0, rNor) << "\";\t--" << line << std::endl;
}


void handleLui(std::string line, int lineNum){
    int r1, imm;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("lui") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<3; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 1:
                if(entry[0] == '$'){
                    r1 = std::stoi(entry.substr(1, entry.size()));
                } else {
                    std::cout << "Error in line " << lineNum << "! Register expected." << std::endl;
                    exit(1);
                }
                break;

            case 2:
                try{
                    imm = std::stoi(entry);
                }
                catch(...){
                    std::cout << "Error in line " << lineNum << "! Unexpected immediate." << std::endl;
                }
                
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }
    out << "\tmem(" << memloc << ")\t<= \"" << luiInstr(r1, imm) << "\";\t--" << line << std::endl;
}

void handleJ(std::string line, int lineNum){
    int address;
    std::stringstream ss(line);
    std::string entry;
    if(!std::getline(ss, entry, ' ') || !entry.compare("j") == 0){
        std::cout << "Error in line " << lineNum << "!" << std::endl;
        exit(1);
    }
    for(int i=1; i<2; ++i){
        if(std::getline(ss, entry, ' ')){

            switch (i){
            case 1:
                if(entry[0] == '.'){
                    if(labels.find(entry) != labels.end()){
                        address = labels[entry] - 1;
                    } else {
                        std::cout << "Error in line " << lineNum << "! Label does not exist!" << std::endl;
                        exit(1);
                    }
                } else {
                    try{
                        address = std::stoi(entry);
                    }
                    catch(...){
                        std::cout << "Error in line " << lineNum << "! Unexpected offset." << std::endl;
                        exit(1);
                    }
                }
                break;
            
            default:
                break;
            }

        } else {
            std::cout << "Error in line " << lineNum << "! Too few operands." << std::endl;
            exit(1);
        }
    }

    out << "\tmem(" << memloc << ")\t<= \"" << jInstr(address) << "\";\t--" << line << std::endl;
}

void handleIdle(std::string line, int lineNum){
    out << "\tmem(" << memloc << ")\t<= \"00000000000000000000000000100000\";\t--" << line << std::endl;
}

void handleExit(std::string line, int lineNum){
    out << "\tmem(" << memloc << ")\t<= \"11111111111111111111111111111111\";\t--" << line << std::endl;
}

std::string rtypeInstr(int r1, int r2, int r3, int shamt, RType type){
    std::string out = "";

    out += "000000";
    out += intToBitString(r2, 5);
    out += intToBitString(r3, 5);
    out += intToBitString(r1, 5);
    out += intToBitString(shamt, 5);;
    switch (type){
    case rAdd:
        out += "100000";
        break;

    case rSub:
        out += "100010";
        break;

    case rAnd:
        out += "100100";
        break;

    case rOr:
        out += "100101";
        break;

    case rNor:
        out += "100111";
        break;

    case rXor:
        out += "100110";
        break;

    case rSll:
        out += "000000";
        break;

    case rSrl:
        out += "000010";
        break;

    case rSra:
        out += "000011";
        break;

    case rSlt:
        out += "101010";
        break;
    
    default:
        break;
    }
    
    return out;
}

std::string lwInstr(int r1, int offset, int r2){
    std::string out = "";

    out += "100011";
    out += intToBitString(r2, 5);
    out += intToBitString(r1, 5);
    out += intToBitString(offset, 16);

    
    return out;
}

std::string swInstr(int r1, int offset, int r2){
    std::string out = "";

    out += "101011";
    out += intToBitString(r2, 5);
    out += intToBitString(r1, 5);
    out += intToBitString(offset, 16);

    
    return out;
}

std::string beqInstr(int r1, int r2, int offset){
    std::string out = "";

    out += "000100";
    out += intToBitString(r1, 5);
    out += intToBitString(r2, 5);
    out += intToBitString(offset, 16);

    
    return out;
}

std::string addiInstr(int r1, int r2, int offset){
    std::string out = "";

    out += "001000";
    out += intToBitString(r2, 5);
    out += intToBitString(r1, 5);
    out += intToBitString(offset, 16);

    
    return out;
}


std::string xoriInstr(int r1, int r2, int imm){
    std::string out = "";

    out += "001110";
    out += intToBitString(r2, 5);
    out += intToBitString(r1, 5);
    out += intToBitString(imm, 16);

    
    return out;
}


std::string luiInstr(int r1, int imm){
    std::string out = "";

    out += "001111";
    out += intToBitString(0, 5);
    out += intToBitString(r1, 5);
    out += intToBitString(imm, 16);

    
    return out;
}



std::string jInstr(int address){
    std::string out = "";

    out += "000010";
    out += intToBitString(address, 26);

    
    return out;
}

std::string intToBitString(int i, int length){
    std::string s;
    switch (length){
    case 1:
        s = std::bitset< 1 >( i ).to_string();
        break;

    case 2:
        s = std::bitset< 2 >( i ).to_string();
        break;

    case 3:
        s = std::bitset< 3 >( i ).to_string();
        break;

    case 4:
        s = std::bitset< 4 >( i ).to_string();
        break;

    case 5:
        s = std::bitset< 5 >( i ).to_string();
        break;

    case 6:
        s = std::bitset< 6 >( i ).to_string();
        break;

    case 7:
        s = std::bitset< 7 >( i ).to_string();
        break;

    case 8:
        s = std::bitset< 8 >( i ).to_string();
        break;

    case 9:
        s = std::bitset< 9 >( i ).to_string();
        break;

    case 10:
        s = std::bitset< 10 >( i ).to_string();
        break;

    case 11:
        s = std::bitset< 11 >( i ).to_string();
        break;

    case 12:
        s = std::bitset< 12 >( i ).to_string();
        break;

    case 13:
        s = std::bitset< 13 >( i ).to_string();
        break;

    case 14:
        s = std::bitset< 14 >( i ).to_string();
        break;

    case 15:
        s = std::bitset< 15 >( i ).to_string();
        break;

    case 16:
        s = std::bitset< 16 >( i ).to_string();
        break;

    case 26:
        s = std::bitset< 26 >( i ).to_string();
        break;

    default:
        break;
    }
    
    return s;
}
