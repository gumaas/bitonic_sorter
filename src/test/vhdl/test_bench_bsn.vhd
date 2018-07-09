-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   Test Bench for Bitonic Sort Network
--!     @version 0.1.0
--!     @date    2015/11/9
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2015 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_BSN is
end     TEST_BENCH_BSN;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
architecture MODEL of TEST_BENCH_BSN is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant CLOCK_PERIOD    : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant WORDS           :  integer :=  8;
    constant WORD_BITS       :  integer :=  9;
    constant COMP_HIGH       :  integer :=  7;
    constant COMP_LOW        :  integer :=  0;
    constant INFO_BITS       :  integer :=  4;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   CLK             :  std_logic;
    signal   RST             :  std_logic;
    signal   CLR             :  std_logic;
    signal   I_SORT          :  std_logic;
    signal   I_UP            :  std_logic;
    signal   I_DATA          :  std_logic_vector(WORDS*WORD_BITS-1 downto 0);
    signal   I_INFO          :  std_logic_vector(      INFO_BITS-1 downto 0);
    signal   O_SORT          :  std_logic;
    signal   O_UP            :  std_logic;
    signal   O_DATA          :  std_logic_vector(WORDS*WORD_BITS-1 downto 0);
    signal   O_INFO          :  std_logic_vector(      INFO_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------

    type      INTEGER_VECTOR  is array(0 to WORDS-1) of integer;

    signal  src_vec_sig         :  INTEGER_VECTOR;
    signal  exp_vec_sig         :  INTEGER_VECTOR;
    signal  res_sig         :  INTEGER_VECTOR;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: entity work.Bitonic_Sorter                 -- 
        generic map (                   -- 
            WORDS     => WORDS        , --
            WORD_BITS => WORD_BITS    , --
            COMP_HIGH => COMP_HIGH    , --
            COMP_LOW  => COMP_LOW     , --
            INFO_BITS => INFO_BITS      --
        )                               -- 
        port map (                      -- 
            RST       => RST          , -- In  :
            CLR       => CLR          , -- In  :
            I_SORT    => I_SORT       , -- In  :
            I_UP      => I_UP         , -- In  :
            I_DATA    => I_DATA       , -- In  :
            I_INFO    => I_INFO       , -- In  :
            O_SORT    => O_SORT       , -- Out :
            O_UP      => O_UP         , -- Out :
            O_DATA    => O_DATA       , -- Out :
            O_INFO    => O_INFO         -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        CLK <= '0';
        wait for CLOCK_PERIOD / 2;
        CLK <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process
        variable  src_vec         :  INTEGER_VECTOR;
        variable  exp_vec         :  INTEGER_VECTOR;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        function  TO_DATA(IVEC:INTEGER_VECTOR; EN: std_logic_vector) return std_logic_vector is
            variable     data :  std_logic_vector(WORDS*WORD_BITS-1 downto 0);
        begin
            for i in 0 to WORDS-1 loop
                data(WORD_BITS*(i+1)-1 downto WORD_BITS*i) := std_logic_vector(EN(i)& to_unsigned(IVEC(i), WORD_BITS-1));
            end loop;
            return data;
        end function;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        function  TO_INTEGER_VECTOR(DATA:std_logic_vector) return INTEGER_VECTOR is
            variable     ivec :  INTEGER_VECTOR;
        begin
            for i in 0 to WORDS-1 loop
                ivec(i) := to_integer(unsigned(DATA(WORD_BITS*(i+1)-1-1 downto WORD_BITS*i)));
            end loop;
            return ivec;
        end function;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure WAIT_CLK(CNT:in integer) is
        begin
            for i in 1 to CNT loop 
                wait until (CLK'event and CLK = '1'); 
            end loop;
        end WAIT_CLK;

        res_sig <= TO_INTEGER_VECTOR(O_DATA);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure TEST(SORT,UP:std_logic; SRC,EXP: INTEGER_VECTOR; EN: std_logic_vector) is
            variable timeout :  boolean;
            variable result  :  INTEGER_VECTOR;
        begin
            I_DATA  <= TO_DATA(SRC, EN);
            I_INFO  <= "1111";
            I_SORT  <= SORT;
            I_UP    <= UP;
            timeout := TRUE;
            src_vec_sig     <= SRC;
            exp_vec_sig     <= EXP;
            
            --wait until (O_EVENT'event and O_EVENT = '1');
            --I_INFO <= "0000";
            --I_DATA <= (others => '0');
            --I_SORT <= '0';
            --I_UP   <= '0';

            result := 
            res_sig     <= result;
            --assert(result  = EXP  ) report "Mismatch..." severity FAILURE;
        end procedure;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        assert(false) report "Run Start..." severity NOTE;
        RST    <= '1';
        CLR    <= '0';
        I_DATA <= (others => '0');
        I_INFO <= (others => '0');
        I_SORT <= '0';
        I_UP   <= '0';
        WAIT_CLK(10);
        RST    <= '0';
        WAIT_CLK(10);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        src_vec := (0 => 8, 1 => 1, 2 => 0, 3 => 6, 4 => 1, 5 => 2, 6 => 9, 7 => 1);
        exp_vec := (0 => 8, 1 => 1, 2 => 0, 3 => 6, 4 => 1, 5 => 2, 6 => 9, 7 => 1);
        

        TEST('0', '0', src_vec, exp_vec, "00111111");

        WAIT_CLK(1);

        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        src_vec := (0 => 8, 1 => 1, 2 => 0, 3 => 6, 4 => 1, 5 => 2, 6 => 9, 7 => 1);
        exp_vec := (0 => 9, 1 => 8, 2 => 6, 3 => 2, 4 => 1, 5 => 1, 6 => 1, 7 => 0);

        TEST('1', '0', src_vec, exp_vec, "11111111");
        WAIT_CLK(1);
        
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        src_vec := (0 => 8, 1 => 1, 2 => 0, 3 => 6, 4 => 1, 5 => 2, 6 => 9, 7 => 1);
        exp_vec := (0 => 0, 1 => 1, 2 => 1, 3 => 1, 4 => 2, 5 => 6, 6 => 8, 7 => 9);

        TEST('1', '1', src_vec, exp_vec, "11000011");
        WAIT_CLK(1);

        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        src_vec := (0 => 0, 1 => 1, 2 => 255, 3 => 250, 4 => 10, 5 => 200, 6 => 10, 7 => 13);
        exp_vec := (0 => 200, 1 => 250, 2 => 255, 3 => 0, 4 => 1, 5 => 10, 6 => 10, 7 => 13);

        TEST('1', '1', src_vec, exp_vec, "11010011");
        WAIT_CLK(1);


        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        src_vec := (0 => 250, 1 => 200, 2 => 230, 3 => 180, 4 => 190, 5 => 220, 6 => 150, 7 => 240);
        exp_vec := (0 => 150, 1 => 180, 2 => 190, 3 => 200, 4 => 220, 5 => 230, 6 => 240, 7 => 250);

        TEST('1', '1', src_vec, exp_vec, "11001100");
        WAIT_CLK(1);


        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        src_vec := (0 => 250, 1 => 200, 2 => 230, 3 => 180, 4 => 190, 5 => 220, 6 => 0, 7 => 240);
        exp_vec := (0 => 180, 1 => 190, 2 => 200, 3 => 220, 4 => 230, 5 => 240, 6 => 250, 7 => 0);

        TEST('1', '1', src_vec, exp_vec, "11110000");
        WAIT_CLK(1);




        WAIT_CLK(10);
        assert(false) report "Run complete..." severity FAILURE;
        wait;
    end process;
end MODEL;
