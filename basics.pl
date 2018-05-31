
:- debug.
:- use_module(library(csv)).

:-dynamic frcMatch/5.
:-dynamic record/3.

% This is some ugly code to load the match data, I need to figure out 
% how to make it more clean... 
processEvent([]).
processEvent([row(ID, R1, R2, R3, B1, B2, B3, RScore, BScore)|T]) :- 
    matchRow(ID, R1, R2, R3, B1, B2, B3, RScore, BScore),
    processEvent(T).

matchRow(ID, R1, R2, R3, B1, B2, B3, RScore, BScore) :- 
    atom_string(MID, ID),   
    assert(frcMatch(MID, [R1, R2, R3], [B1, B2, B3], RScore, BScore)).

loadEvent(Year, EventCode) :- 
    swritef(Path, 'tba-data/events/%w/%w/%w_matches.csv', [Year, EventCode, EventCode]),
    csv_read_file(Path, Data, []),
    processEvent(Data).


% Here's the fun methods that filter match data... 

played(Team, Match) :- 
    frcMatch(Match, Red, _, _, _),
    subset(Team, Red);
    frcMatch(Match, _, Blue, _, _),
    subset(Team, Blue).

won(Team, Match) :- 
    frcMatch(Match, Red, _, RScore, BScore),
    subset(Team, Red),
    RScore > BScore;
    frcMatch(Match, _, Blue, RScore, BScore),
    subset(Team, Blue),
    BScore > RScore.


tied(Team, Match) :- 
    played(Team, Match),
    frcMatch(Match, _, _, RScore, BScore),
    RScore = BScore.

% Ex - find all matches a team lost:
% findall(MatchId, lost([frc2056], MatchId), Matches)
lost(Team, Match) :- 
    played(Team, Match),
    not(won(Team, Match)),
    not(tied(Team, Match)).


% As a fun query, let's find a team's record...
record(Team) :- 
    findall(W, won(Team, W), Wins),
    findall(T, tied(Team, T), Ties),
    findall(L, lost(Team, L), Losses),
    length(Wins, WinCount),
    length(Ties, TieCount),
    length(Losses, LossCount),
    write([WinCount, LossCount, TieCount]).