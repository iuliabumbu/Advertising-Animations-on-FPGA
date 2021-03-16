library work, std;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity reclama is
	port(  a: in std_logic_vector(2 downto 0);	--pt selectii 
	clk: in bit;
	an: inout std_logic_vector (3 downto 0):="1110"; --pt cei 4 anozi
	af: out std_logic_vector(6 downto 0)); --pt afisorul 7 segmente
end reclama; 

architecture arh_comp of reclama is

--clk placutei e de 100MHz: 10^8~2^27	  
--100Mhz/2^17~763 Hz
--1/763~0.0013=1,3 msec => fiecare litera va fi aprinsa pt cca 13 msec, perioada de improspatare devenind 4*1,3=5,2 msec care apartine (1,16)msec
signal count: std_logic_vector(26 downto 0):=(others=>'0');--folosit pentru intarzierea urmatoarei faze cu aproximativ o secunda	
signal count1: std_logic_vector(25 downto 0):=(others=>'0');--folosit pentru intarzierea urmatoarei faze cu mai putin de o secunda
signal count_a: std_logic_vector(16 downto 0):=(others=>'0');--folosit pentru intarzierea schimbarii anodului pt a fi perceptibila	afisarea

type alfabet is array (25 downto 0) of std_logic_vector (6 downto 0);
type anim1 is array (7 downto 0) of std_logic_vector (6 downto 0);
type anim2 is array (15 downto 0) of std_logic_vector (6 downto 0);
type anim3 is array (31 downto 0) of std_logic_vector (6 downto 0);
type anim4 is array (15 downto 0) of std_logic_vector (6 downto 0);
type anim5 is array (31 downto 0) of std_logic_vector (6 downto 0); 
type anim6 is array (107 downto 0) of std_logic_vector (6 downto 0); 
type anim7 is array (15 downto 0) of std_logic_vector (6 downto 0);

constant l: alfabet:=(
0 => "1111111", -- spatiu    
1 => "0001000", -- A		 
2 => "1100000", -- B
3 => "0110001", -- C
4 => "1000010", -- D
5 => "0110000", -- E
6 => "0111000", -- F
7 => "0100000", -- G
8 => "1101000", -- H
9 => "1111001", -- I
10 => "1000111", -- J
11 => "1111001", -- K
12 => "1110001", -- L
13 => "0101010", -- M
14 => "1101010", -- N
15 => "0000001", -- O
16 => "0011000", -- P
17 => "1111010", -- R
18 => "0100100", -- S
19 => "0111001", -- T
20 => "1000001", -- U
21 => "1100011", -- V
22 => "1000000", -- W
23 => "1001000", -- X
24 => "1001100", -- Y
25 => "0010010");  -- Z

--pt animatia1: palpaire 
constant c1:anim1:=(
0 =>l(18),	--S
1 =>l(3),	--C
2 =>l(15),	--O
3 =>l(16),	--P
 
4 =>l(0),	--
5 =>l(0),	--
6 =>l(0),	--
7 =>l(0));	--	

--pt animatia2: afisare litera cu litera  
constant c2: anim2:=(
0 =>l(18),	--S
1 =>l(0),	--
2 =>l(0),	--
3 =>l(0),	--

4 =>l(0),	--
5 =>l(3),	--C
6 =>l(0),	--
7 =>l(0),	--

8 =>l(0),   --
9 =>l(0),	--
10 =>l(15),	--O
11 =>l(0),	--

12 =>l(0),	--
13 =>l(0),	--
14 =>l(0),	--
15 =>l(16)); --P

--pt animatia 3: deplasare dreapta-stanga
constant c3: anim3:=(
0 =>l(18),	--S
1 =>l(3),	--C
2 =>l(15),	--O
3 =>l(16),	--P	 

4 =>l(0),	--
5 =>l(0),	--
6 =>l(0),	--
7 =>l(0),	--

8  =>l(3),	--C
9  =>l(15),	--O
10 =>l(16),	--P
11 =>l(18),	--S	  

12 =>l(0),	--
13 =>l(0),	--
14 =>l(0),	--
15 =>l(0),	--

16 =>l(15), --O
17 =>l(16),	--P
18 =>l(18),	--S
19 =>l(3),	--C	 

20 =>l(0),  --				
21 =>l(0),	--
22 =>l(0),	--
23 =>l(0),	--

24 =>l(16),	--P
25 =>l(18),	--S
26 =>l(3),	--C
27 =>l(15), --0	

28 =>l(0),  --				
29 =>l(0),	--
30 =>l(0),	--
31 =>l(0));	--

--pt animatia 4: aparitie litere succesiv
constant c4: anim4:=(
0 =>l(18),	--S
1 =>l(0),	--
2 =>l(0),	--
3 =>l(0),	--	  

4 =>l(18),	--S
5 =>l(3),	--C
6 =>l(0),	--
7 =>l(0),	--

8 =>l(18),  --S
9 =>l(3),	--C
10 =>l(15),	--O
11 =>l(0),	--

12 =>l(18),	--S
13 =>l(3),	--C
14 =>l(15),	--O
15 =>l(16));--P 

--pt animatia 5: afisare cuvant si literele constituente intercalat
constant c5:anim5:=(
0 =>l(18),	--S
1 =>l(3),	--C
2 =>l(15),	--O
3 =>l(16),	--P		

4 =>l(18),	--S
5 =>l(0),	--
6 =>l(0),	--
7 =>l(0),	--

8 =>l(18),	--S
9 =>l(3),	--C
10 =>l(15),	--O
11 =>l(16),	--P	

12 =>l(0),	--
13 =>l(3),	--C
14 =>l(0),	--
15 =>l(0),	--

16 =>l(18),	--S
17 =>l(3),	--C
18 =>l(15),	--O
19 =>l(16),	--P	

20 =>l(0),   --				
21 =>l(0),	--
22 =>l(15),	--O
23 =>l(0),	--	 

24 =>l(18),	--S
25 =>l(3),	--C
26 =>l(15),	--O
27 =>l(16),	--P	

28 =>l(0),	--
29 =>l(0),	--
30 =>l(0),	--
31 =>l(16)); --P 

--pt animatia 6: "elastic"	
constant c6:anim6:=(
0 =>l(18),	--S
1 =>l(3),	--C
2 =>l(15),	--O
3 =>l(16),	--P		

4 =>l(0),	--
5 =>l(0),	--
6 =>l(0),	--
7 =>l(0),	--

8 =>l(0),	--
9 =>l(0),	--
10 =>l(0),	--
11 =>l(0),	--

12 =>l(0),	--
13 =>l(0),	--
14 =>l(0),	--
15 =>l(0),	--

16 =>l(0),	--
17 =>l(0),	--
18 =>l(0),	--
19 =>l(0),	--

20 =>l(0),  --				
21 =>l(0),	--
22 =>l(0),	--
23 =>l(0),	--	 

24 =>l(0),	--
25 =>l(0),	--
26 =>l(0),	--
27 =>l(0),	--

28 =>l(18),	--S
29 =>l(3),	--C
30 =>l(15),	--O
31 =>l(16), --P	   

32 =>l(0),	--
33 =>l(0),	--
34 =>l(0),	--
35 =>l(0),  --	

36 =>l(0),	--
37 =>l(0),	--
38 =>l(0),	--
39 =>l(0),  --	

40 =>l(0),	--
41 =>l(0),	--
42 =>l(0),	--
43 =>l(0),  --	

44 =>l(0),	--
45 =>l(0),	--
46 =>l(0),	--
47 =>l(0),  --	

48 =>l(0),	--
49 =>l(0),	--
50 =>l(0),	--
51 =>l(0),  --

52 =>l(18),	--S
53 =>l(3),	--C
54 =>l(15),	--O
55 =>l(16), --P	

56 =>l(0),	--
57 =>l(0),	--
58 =>l(0),	--
59 =>l(0),  --	

60 =>l(0),	--
61 =>l(0),	--
62 =>l(0),	--
63 =>l(0),  --	

64 =>l(0),	--
65 =>l(0),	--
66 =>l(0),	--
67 =>l(0),  --	

68 =>l(0),	--
69 =>l(0),	--
70 =>l(0),	--
71 =>l(0),  --

72 =>l(18),	--S
73 =>l(3),	--C
74 =>l(15),	--O
75 =>l(16), --P	

76 =>l(0),	--
77 =>l(0),	--
78 =>l(0),	--
79 =>l(0),  --	

80 =>l(0),	--
81 =>l(0),	--
82 =>l(0),	--
83 =>l(0),  --	

84 =>l(0),	--
85 =>l(0),	--
86 =>l(0),	--
87 =>l(0),  --	

88 =>l(18),	--S
89 =>l(3),	--C
90 =>l(15),	--O
91 =>l(16), --P	

92 =>l(0),	--
93 =>l(0),	--
94 =>l(0),	--
95 =>l(0),  --	

96 =>l(0),	--
97 =>l(0),	--
98 =>l(0),	--
99 =>l(0),  --

100 =>l(18),--S
101 =>l(3),	--C
102 =>l(15),--O
103 =>l(16), --P	

104 =>l(0),	--
105 =>l(0),	--
106 =>l(0),	--
107 =>l(0));  --	
	
--pt animatia 7: curgere din stanga si din dreapta
constant c7: anim7:=(
0 =>l(0),	--
1 =>l(0),	--
2 =>l(0),	--
3 =>l(0),	--	  

4 =>l(3),	--C
5 =>l(0),	--
6 =>l(0),	--
7 =>l(15),	--O

8 =>l(0),   --
9 =>l(3),	--C
10 =>l(15),	--O
11 =>l(0),	--

12 =>l(18),	--S
13 =>l(3),	--C
14 =>l(15),	--O
15 =>l(16));--P 

begin
	
animatii: process(clk)
variable i: natural:=0;	--va creste cu 4 unitati aproximativ din secunda in secunda asigurand incarcarea urmatoarelor 4 constante
begin
	if clk'event and clk='1' then
		case a is  
			--1---------------------------------------------------------
			when "001" => --palpaire 
			--deschidem pe rand cate un anod:	
			if(count_a="10000000000000000")then  
			  if(an(0)='0') then
				an(0)<='1';
				af<=c1(i);
				an(3)<='0';
			  elsif (an(3)='0') then
				an(3)<='1';
				af<=c1(i+1);
				an(2)<='0';
			  elsif (an(2)='0') then
				an(2)<='1';
				af<=c1(i+2);
				an(1)<='0';	
			  elsif (an(1)='0') then
				an(1)<='1';
				af<=c1(i+3);
				an(0)<='0';
			  end if;	 
			end if;
		    if(count_a="10000000000000000") then
	    		count_a<=(others=>'0');
		    end if;
		count_a<=count_a+1;	
		count<=count+1;	 
		if i=8 then
			i:=0;
		end if;	 
		--incarcam urmatoarea faza
		if(count="100000000000000000000000000")	then
			i:=i+4;
			count<=(others=>'0');
		end if;	
		--2---------------------------------------------------
		when "010"=> --afisare litera cu litera
		--deschidem pe rand cate un anod:	
		 if(count_a="10000000000000000")then	
			if(an(0)='0') then
				an(0)<='1';
				af<=c2(i);
				an(3)<='0';
			elsif (an(3)='0') then
				an(3)<='1';
				af<=c2(i+1);
				an(2)<='0';
			elsif (an(2)='0') then
				an(2)<='1';
				af<=c2(i+2);
				an(1)<='0';	
			elsif (an(1)='0') then
				an(1)<='1';
				af<=c2(i+3);
				an(0)<='0';
			end if;	  
		end if;
		    if(count_a="10000000000000000") then
	    		count_a<=(others=>'0');
		    end if;
		count_a<=count_a+1;
		count<=count+1;
		if i=16 then
			i:=0;
		end if;	   
		--incarcam urmatoarea faza
		if(count="100000000000000000000000000")	then	
			i:=i+4;
			count<=(others=>'0');
		end if;	
		--3--------------------------------------------------------	
		when "011"=> --deplasare dreapta-stanga   
		--deschidem pe rand cate un anod:	
		if(count_a="10000000000000000")then	 
		if(an(0)='0') then
				an(0)<='1';
				af<=c3(i);
				an(3)<='0';
			elsif (an(3)='0') then
				an(3)<='1';
				af<=c3(i+1);
				an(2)<='0';
			elsif (an(2)='0') then
				an(2)<='1';
				af<=c3(i+2);
				an(1)<='0';	
			elsif (an(1)='0') then
				an(1)<='1';
				af<=c3(i+3);
				an(0)<='0';
			end if;	 
			end if;
			if(count_a="10000000000000000") then
	    		count_a<=(others=>'0');
			end if;
		count_a<=count_a+1;
		count<=count+1;
		if i=32 then
			i:=0;
		end if;	 
		--incarcam urmatoarea faza
		if(count="100000000000000000000000000")	then
			i:=i+4;
			count<=(others=>'0');
		end if;	
		--4--------------------------------------------------------
		when "100"=> --aparitie litere succesiv
		--deschidem pe rand cate un anod:	
		  if(count_a="10000000000000000")then	   
		if(an(0)='0') then
				an(0)<='1';
				af<=c4(i);
				an(3)<='0';
			elsif (an(3)='0') then
				an(3)<='1';
				af<=c4(i+1);
				an(2)<='0';
			elsif (an(2)='0') then
				an(2)<='1';
				af<=c4(i+2);
				an(1)<='0';	
			elsif (an(1)='0') then
				an(1)<='1';
				af<=c4(i+3);
				an(0)<='0';
			end if;	
		end if;
			if(count_a="10000000000000000") then
	    		count_a<=(others=>'0');
			end if;
		count_a<=count_a+1;
		count<=count+1;
		if i=16 then
			i:=0;
		end if;	   
		--incarcam urmatoarea faza
		if(count="100000000000000000000000000")	then
			i:=i+4;
			count<=(others=>'0');
		end if;	
		--5---------------------------------------------------
		when "101"=>  --afisare cuvant si literele constituente intercalat 
		--deschidem pe rand cate un anod:	
		if(count_a="10000000000000000")then	 							
		if(an(0)='0') then
				an(0)<='1';
				af<=c5(i);
				an(3)<='0';
			elsif (an(3)='0') then
				an(3)<='1';
				af<=c5(i+1);
				an(2)<='0';
			elsif (an(2)='0') then
				an(2)<='1';
				af<=c5(i+2);
				an(1)<='0';	
			elsif (an(1)='0') then
				an(1)<='1';
				af<=c5(i+3);
				an(0)<='0';
			end if;	   
	    	end if;
		if(count_a="10000000000000000") then
	    	count_a<=(others=>'0');
		end if;
		count_a<=count_a+1;
		count<=count+1;
		if i=32 then
			i:=0;
		end if;	 
		--incarcam urmatoarea faza
		if(count="100000000000000000000000000")	then	
			i:=i+4;
			count<=(others=>'0');
		end if;	
		--6------------------------------------------------------ 
		when "110"=> --"elastic" 
		--deschidem pe rand cate un anod:	
		  if(count_a="10000000000000000")then	 
			if(an(0)='0') then
				an(0)<='1';
				af<=c6(i);
				an(3)<='0';
			elsif (an(3)='0') then
				an(3)<='1';
				af<=c6(i+1);
				an(2)<='0';
			elsif (an(2)='0') then
				an(2)<='1';
				af<=c6(i+2);
				an(1)<='0';	
			elsif (an(1)='0') then
				an(1)<='1';
				af<=c6(i+3);
				an(0)<='0';
			end if;	 
			end if;
			if(count_a="10000000000000000") then	
	    		count_a<=(others=>'0');
			end if;
		count_a<=count_a+1;
		count1<=count1+1;
		if i=108 then
			i:=0;
		end if;	  
		--incarcam urmatoarea faza
		if(count1="10000000000000000000000000")	then  
			i:=i+4;
			count1<=(others=>'0');
		end if;
		--7------------------------------------------------- 
		when "111"=> --curgere din stanga si din dreapta  
		--deschidem pe rand cate un anod:	
		  if(count_a="10000000000000000")then	 
			if(an(0)='0') then
				an(0)<='1';
				af<=c7(i);
				an(3)<='0';
			elsif (an(3)='0') then
				an(3)<='1';
				af<=c7(i+1);
				an(2)<='0';
			elsif (an(2)='0') then
				an(2)<='1';
				af<=c7(i+2);
				an(1)<='0';	
			elsif (an(1)='0') then
				an(1)<='1';
				af<=c7(i+3);
				an(0)<='0';
			end if;	 
			end if;
			if(count_a="10000000000000000") then	
	    		count_a<=(others=>'0');
			end if;
		count_a<=count_a+1;
		count<=count+1;
		if i=16 then
			i:=0;
		end if;		  
		--incarcam urmatoarea faza
		if(count="100000000000000000000000000")	then  
			i:=i+4;
			count<=(others=>'0');
		end if;
		---------------------------------------------------
		when others=>	 
		--daca nu am ales una dintre codificarile animatiilor afisam EEEE
		an<="0000";
		af<=l(5);
		
		end case; 
		end if;
	end process animatii;
end architecture;	
