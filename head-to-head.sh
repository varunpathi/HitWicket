# Initializing the variables
count=0;
team1_max_score=0;
team2_max_score=0;
team1_min_score=390;
team2_min_score=390;
match_code_team1_max_score=0;
match_code_team2_max_score=0;
match_code_team1_min_score=0;
match_code_team2_min_score=0;
team1_max_wickets=0
team2_max_wickets=0
team1_min_wickets=11
team2_min_wickets=11
match_code_team1_max_wickets=0
match_code_team2_max_wickets=0
match_code_team1_min_wickets=0
match_code_team2_min_wickets=0
team1_max_margin_score=0
team2_max_margin_score=0
team1_min_margin_score=300
team2_min_margin_score=300
match_code_team1_max_margin_score=0
match_code_team1_min_margin_score=0
match_code_team2_max_margin_score=0
match_code_team2_min_margin_score=0

# Fetching the matches for the team
start=`echo http://staging.hitwicket.com/team/matches/`
paging=http://staging.hitwicket.com/league/show/1;
#pagiing=`echo $paging1`;
checkpoint=0
# Identifying the current season
current_season=`curl --silent $paging|grep "season_id="|head -1|cut -d'=' -f4|tr -d [:punct:]|tr -d [:alpha:]|tr -d ' ' |tr -d '\n'`;
#echo $current_season

# Command Args  Validation 
	if [ $# -eq 2 ]
	then 
	team1=`echo $1`
	team2=`echo $2`
	else
	echo -e "   Please Enter team 1 code \c "
	read team1
	echo -e "   Please Enter team 2 code \c "
	read team2
	fi
	#Erasing Old files to avoid OverWriting
		if [ -e "matches_won_$team1$team2.dat" ]
		then 
		rm matches_won_$team1$team2.dat 
		fi
		if [ -e "comments_n_notable_$team1$team2" ]
		then
		rm comments_n_notable_$team1$team2
		fi
# Iterating across the seasons to Identify the games between the teams	
   	for j in $(seq 1 $current_season) 
   	do
		URL=`echo $start$team1\?season_id=$j`;    
	#	echo $URL;
		URL1=`echo $start$team2\?season_id=$j`;
		curl --Silent $URL -o team_1_seasonid;curl --Silent $URL1 -o team_2_seasonid;
# Avoid games played by Earlier team manager. Should concentrate on the games by current manager. Start by  Clip games of Older management
		if [ `cat team_1_seasonid|grep -i "Show matches under old management"|wc -l` -eq 0 -a `cat team_2_seasonid|grep -i "Show matches under old management"|wc -l` -eq 0 ]
		then 
		links=`cat team_1_seasonid|grep -v "match big_line"|sed -e '/practise match/,+6d'|sed -e '/cup match/,+6d'|sed -e '/instant match/,+6d'|grep -i "/match/show/"|cut -d'/' -f4`;
		elif [ `cat team_1_seasonid|grep -in "Show matches under old management"|head -1|cut -d':' -f1` -gt `cat team_1_seasonid|grep -in "/match/show/"|head -1|cut -d':' -f1`  ]
		then
		if [ `cat team_2_seasonid|grep -i "Show matches under old management"|wc -l` -eq 0 -o `cat team_2_seasonid|grep -in "Show matches under old management"|head -1|cut -d':' -f1` -gt `cat team_2_seasonid|grep -in "/match/show/"|head -1|cut -d':' -f1` ]
		then
		limit=`cat team_1_seasonid|grep -in "Show matches under old management"|head -1|cut -d':' -f1`
		limit2=`cat team_2_seasonid|grep -in "Show matches under old management"|head -1|cut -d':' -f1`
		if [ $limit -gt $limit2 ]
		then
		limit1=$limit;
		else
		limit1=$limit2;
		fi
		links=`cat team_1_seasonid|head -$limit1|grep -v "match big_line"|sed -e '/practise match/,+6d'|sed -e '/cup match/,+6d'|sed -e '/instant match/,+6d'|grep -i "/match/show/"|cut -d'/' -f4`;
		fi
		fi
#echo links$links;
# Loop over the links to collect the statistics like the maximum/minimum scores between the teams.
	 	for i in `echo $links`
        	do
	
			URL2=`echo http://staging.hitwicket.com/match/show/`;
			URL2=`echo $URL2$i`
        
		        curl --silent $URL2  -o page;
		        page=`cat page`;
			page1=`cat page|grep team_name|grep -i "/team/show/$team2"`;
		        if [ `cat page|grep -i "practise match"|wc -l` -eq 0 -a `cat page|grep -i "cup match"|wc -l` -eq 0 -a `cat page|grep -i "instant match"|wc -l` -eq 0 ]
			then
	   		if [ "`echo $page1|grep $team2|cut -d'/' -f4`" == "$team2" ]
              		then
			
			if [ `cat page|grep "team/show/"|grep -n $team1|head -1|cut -d':' -f1` -lt `cat page|grep "team/show/"|grep -n $team2|head -1|cut -d':' -f1` ]
			then 

			team1_score=`cat page|grep -iv "current_score"|grep -iv "current_over"|grep -i "current_total"|head -1|cut -d'>' -f2|cut -d'/' -f1`
			team2_score=`cat page|grep -iv "current_score"|grep -iv "current_over"|grep -i "current_total"|tail -1|cut -d'>' -f2|cut -d'/' -f1`
			else
			team1_score=`cat page|grep -iv "current_score"|grep -iv "current_over"|grep -i "current_total"|tail -1|cut -d'>' -f2|cut -d'/' -f1`
			team2_score=`cat page|grep -iv "current_score"|grep -iv "current_over"|grep -i "current_total"|head -1|cut -d'>' -f2|cut -d'/' -f1`
			fi
			echo -e " \n $URL2 \n"
			if [ $team1_score -ge $team1_max_score ]
			then
			team1_max_score=$team1_score;
			match_code_team1_max_score=$i;
			fi
			if [ $team2_score -ge $team2_max_score ]
        	        then
                        team2_max_score=$team2_score ;                                                                                        
                        match_code_team2_max_score=$i;
                	fi 
			if [ $team1_score -le $team1_min_score ]
			then
			team1_min_score=$team1_score;
			match_code_team1_min=$i;
			fi

			if [ $team2_score -le $team2_min_score ]                                                                              
			then
                        team2_min_score=$team2_score;
                        match_code_team2_min=$i;                                                                                              
                	fi 
			if [ `expr $team1_score - $team2_score ` -ne 0 ]
			then
			URL_player=http://staging.hitwicket.com/player/show/`cat page|grep -i "player/show/"| cut -d'/' -f4|cut -d'"' -f1`
			#echo $URL_player	
			curl --Silent $URL_player -o player_page
			impact_player_team=`cat player_page|grep -i big_team_name|head -1|cut -d'/' -f4|cut -d'"' -f1`
	
		#	echo $impact_player_team
# Identification of player having the maximum impact.
			state=1
			
			if [ `cat player_page|grep -i retire|wc -l` -ne 0 ]
			then
			impact_player_team=0
			state=r
			fi
			if [ $impact_player_team -ne `cat page|grep team_name|grep -i "/team/show/$team2"|head -1|cut -d'/' -f4` -a $impact_player_team -ne `cat page|grep team_name|grep -i "/team/show/$team1"|head -1|cut -d'/' -f4` -a $impact_player_team -ne 0 ]
			then
			state=t
			URL_transfer=`echo http://staging.hitwicket.com/team/transferHistory/$team1`
			curl --Silent $URL_transfer -o transferpage
			number_of_pages=`cat transferpage|grep -i "class=\"page\""|tail -1|cut -d'=' -f4|cut -d'"' -f1`
			for p in $(seq 1 $number_of_pages)
			do
			URL_transfer=`echo http://staging.hitwicket.com/team/transferHistory/$team1\?Transfer_page=$p`
			curl --Silent $URL_transfer -o transferpage
			playercode=`cat page|grep -i "player/show/"| cut -d'/' -f4|cut -d'"' -f1`
			checkpoint=0
			if [ `cat transferpage|grep "player/show/$playercode"|wc -l` -gt 0 ]
			then
			impact_player_team=$team1
			checkpoint=$impact_player_team
			fi
			done
# What if the impact player has been transferred to another team
			 URL_transfer=`echo http://staging.hitwicket.com/team/transferHistory/$team2`
                        curl --Silent $URL_transfer -o transferpage
			number_of_pages=`cat transferpage|grep -i "class=\"page\""|tail -1|cut -d'=' -f4|cut -d'"' -f1`

			for p in $(seq 1 $number_of_pages)                                                                                                    
                        do
			URL_transfer=`echo http://staging.hitwicket.com/team/transferHistory/$team2\?Transfer_page=$p`
			curl --Silent $URL_transfer -o transferpage
                        playercode=`cat page|grep -i "player/show/"| cut -d'/' -f4|cut -d'"' -f1`
			if [ `cat transferpage|grep "player/show/$playercode"|wc -l` -gt 0 ]                                                  
                        then
                        impact_player_team=$team2
                        fi
			done
			fi
			
			if [ $impact_player_team -ne `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` -a $impact_player_team -ne 0 ]
			then 
			state=l
			elif [ $impact_player_team -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` -a $impact_player_team -ne 0 ]
			then 
			state=1
			fi
			#echo "$checkpoint  $impact_player_team $state<<<<<<"
			if [ $checkpoint -ne 0 -a $impact_player_team -ne $team1 -a "$state" != "r" ]
			then 
			state=it
			fi
# Stats like max/min margin by wickets or runs
			echo $team1 \| vs \| $team2 \| match won by \| `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` \| on \| `cat page|grep "pitch_des"|head -1|cut -d',' -f2,3|cut -d'-' -f1` \| pitch type \| `cat page|grep "pitch"|head -1 |cut -d'>' -f2|cut -d'<' -f1` \| `cat page|grep -i "player/show/"| cut -d'/' -f4|cut -d'"' -f1` \| `cat page|grep -i "player/show/"| cut -d'>' -f2|cut -d'<' -f1`\|$URL2\|$state >> matches_won_$team1$team2.dat					
			type_or_margin=`cat page|grep "wins by"|cut -d'>' -f4|cut -d'<' -f1|tail -1|cut -d' ' -f5`
		        margin=`cat page|grep "wins by"|cut -d'>' -f4|cut -d'<' -f1|tail -1|cut -d' ' -f4`
			echo $margin 
			if [ "$type_or_margin" == "runs" -a $margin -gt $team1_max_margin_score -a $team1 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` ]
			then 
			team1_max_margin_score=$margin;
			match_code_team1_max_margin_score=$i;
			fi
			if [ "$type_or_margin" == "runs" -a $margin -lt $team1_min_margin_score -a $team1 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1`  ]
			then 
			team1_min_margin_score=$margin;
			match_code_team1_min_margin_score=$i;
			fi

			if [ "$type_or_margin" == "runs" -a $margin -gt $team2_max_margin_score -a $team2 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` ]                                    
                        then
                        team2_max_margin_score=$margin;                                                                       
                        match_code_team2_max_margin_score=$i;
                        fi
                        if [ "$type_or_margin" == "runs" -a $margin -lt $team2_min_margin_score -a $team2 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` ]
                        then
                        team2_min_margin_score=$margin;
                        match_code_team2_min_margin_score=$i;
                        fi		

			if [ "$type_or_margin" == "wickets" -a $margin -gt $team1_max_wickets -a $team1 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` ]
                        then
                        team1_max_wickets=$margin;                                                                       
                        match_code_team1_max_wickets=$i;
                        fi  

                        if [ "$type_or_margin" == "wickets" -a $margin -lt $team1_min_wickets -a $team1 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1`  ]
                        then
                        team1_min_wickets=$margin;
                        match_code_team1_min_wickets=$i;
                        fi

                        if [ "$type_or_margin" == "wickets" -a $margin -gt $team2_max_wickets -a $team2 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` ]
                        then
                        team2_max_wickets=$margin;
                        match_code_team2_max_wickets=$i;                                                                 
                        fi  
                        if [ "$type_or_margin" == "wickets" -a $margin -lt $team2_min_wickets -a $team2 -eq `cat page|grep class|grep result|cut -d'/' -f4|cut -d'"' -f1` ]                                                                                                      
                        then
                        team2_min_wickets=$margin;                                                                       
                        match_code_team2_min_wickets=$i;                                                                
                        fi
			
			else
			echo $team1 \| vs \| $team2 \| match tie \| 0000 \| on  \| `cat page|grep "pitch_des"|head -1|cut -d',' -f2,3|cut -d'-' -f1` \| pitch type \| `cat page|grep "pitch"|head -1 |cut -d'>' -f2|cut -d'<' -f1` \| `cat page|grep -i "player/show/"| cut -d'/' -f4|cut -d'"' -f1` \| `cat page|grep -i "player/show/"| cut -d'>' -f2|cut -d'<' -f1`\| $URL2\|1>> matches_won_$team1$team2.dat
			
			fi 
			#if [ $count -eq 0 ]
			#then
			team1_name=`cat page|grep team_name |grep $team1|cut -d'/' -f5|cut -d'"' -f1|tr '-' ' '`
			team2_name=`cat page|grep team_name |grep $team2|cut -d'/' -f5|cut -d'"' -f1|tr '-' ' '`
			#count=1
			#fi 
				pre_comments=`cat page|grep -i "pre match comments"|wc -l`	
				total_comments=`cat page|grep -i "match comments"|wc -l`
			if [ $total_comments -ge 1 ]
			then
			if [ $pre_comments -ge 1 ]
			then
			for k in $(seq 1 $pre_comments)
			do
				echo -e  Pre match comments  `cat page|grep "<p>"|head -$k|tail -1|cut -d'"' -f2`  by `cat page|grep "</small>"|head -$k|tail -1|cut -d'<' -f1` >> matches_won_$team1$team2.dat
				echo -e "\n">>matches_won_$team1$team2.dat
			done
			fi
			pre_comments=`expr $pre_comments + 1 `
			for h in $(seq $pre_comments $total_comments) 
			do
				echo Post match comments `cat page|grep "<p>"|head -$h|tail -1|cut -d'"' -f2` by `cat page|grep "</small>"|head -$h|tail -1|cut -d'<' -f1` >> matches_won_$team1$team2.dat
				echo -e "\n">>matches_won_$team1$team2.dat
			done
			fi
			fi
			fi
		done
		
 	done
# Setting UNDEF/NULL for attributes that couldnot be achieved		
			if [ $team1_min_margin_score -eq 300 ]
			then
			team1_min_margin_score=undefined
			fi 
			 if [ $team2_min_margin_score -eq 300 ]                                                                               
		        then
		        team2_min_margin_score=undefined                                                                                      
		        fi
			 if [ $team2_min_wickets -eq 11 ]
		        then
		        team2_min_wickets=undefined
		        fi
			 if [ $team1_min_wickets -eq 11 ]                                                                                     
		        then
		        team1_min_wickets=undefined                                                                                           
		        fi

			if [ $team1_max_margin_score -eq 0 ]                                                                                
		        then
		        team1_max_margin_score=undefined                                                                                      
		        fi
			if [ $team2_max_margin_score -eq 0 ]
		        then
		        team2_max_margin_score=undefined
		        fi  
		         if [ $team2_max_wickets -eq 0 ]                                                                                     
		        then
		        team2_max_wickets=undefined                                                                                           

		        fi

		         if [ $team1_max_wickets -eq 0 ]

		        then

		        team1_max_wickets=undefined
		        fi

			if [ $team1_max_score -eq 0 ]
		        then
		        team1_max_score=undefined
		        fi
		         if [ $team2_max_score -eq 0 ]
		        then
		        team2_max_score=undefined
		        fi

		        if [ $team1_min_score -eq 390 ]

		        then

		        team1_min_score=undefined

		        fi

		         if [ $team2_min_score -eq 390 ]

		        then

		        team2_min_score=undefined
		        fi
# Interesting comments on the match extracted to take you down the memory lane
		
			echo -e "\n *********************** A Few Match Comments *********************** \n"|tee -a comments_n_notable_$team1$team2
# Phew ! Done coding lets display what we have

			cat -v  matches_won_$team1$team2.dat|grep -v ^[[:digit:]]|tee -a comments_n_notable_$team1$team2
			echo -e "\n \t######################### $team1 $team1_name ##############################\n highest margin of victory in terms of  runs is $team1_max_margin_score \n lowest margin of victory in terms of  runs is $team1_min_margin_score \n highest margin of victory in terms of wickets is $team1_max_wickets \n lowest  margin of victory in terms of wickets is $team1_min_wickets \n highest score against $team2 is $team1_max_score \n lowest score against $team2 is $team1_min_score \n"|tee -a matches_won_$team1$team2.dat
			for i in `cat matches_won_$team1$team2.dat|grep ^[[:digit:]]|cut -d'|' -f9|cut -d' ' -f2|sort|uniq`
			do

				if [ `cat matches_won_$team1$team2.dat |grep ^[[:digit:]]| grep -i $i|cut -d'|' -f5|grep $team1|wc -l`  -ne 0 ]
				then
				 echo -e "\t Wins on $i `cat matches_won_$team1$team2.dat | grep ^[[:digit:]]|grep -i $i|cut -d'|' -f5|grep $team1|wc -l`"|tee -a matches_won_$team1$team2.dat
				fi
			done
			echo -e "\n \t######################### $team2 $team2_name ################################\n \n highest margin of victory in terms of  runs is $team2_max_margin_score \n lowest margin of victory in terms of runs is $team2_min_margin_score \n highest margin of victory in terms of wickets is $team2_max_wickets \n lowest margin of victory in terms of wickets is $team2_min_wickets \n highest score against $team1 is $team2_max_score \n lowest score against $team1 is $team2_min_score \n"|tee -a matches_won_$team1$team2.dat
			for i in `cat matches_won_$team1$team2.dat|grep ^[[:digit:]]|cut -d'|' -f9|cut -d' ' -f2|sort|uniq`
		        do
			        if [ `cat matches_won_$team1$team2.dat |grep ^[[:digit:]]| grep -i $i|cut -d'|' -f5|grep $team2|wc -l`  -ne 0 ]                                          
			        then
				 echo -e "\t Wins on $i `cat matches_won_$team1$team2.dat | grep ^[[:digit:]]|grep -i $i|cut -d'|' -f5|grep $team2|wc -l`"|tee -a matches_won_$team1$team2.dat
			        fi
		        done	
			for i in `cat matches_won_$team1$team2.dat|grep ^[[:digit:]]|cut -d'|' -f9|cut -d' ' -f2|sort|uniq`
                        do

                                if [ `cat matches_won_$team1$team2.dat |grep ^[[:digit:]]| grep -i $i|cut -d'|' -f5|grep 0000|wc -l`  -ne 0 ]
                                then

                                 echo -e "\t Ties on $i `cat matches_won_$team1$team2.dat | grep ^[[:digit:]]|grep -i $i|cut -d'|' -f5|grep 0000|wc -l`"|tee -a matches_won_$team1$team2.dat
                                fi
                        done
                        echo -e "\n ************************ Few notable players for $team1_name *********************** \n"|tee -a comments_n_notable_$team1$team2
			 cat matches_won_$team1$team2.dat|grep -i ^[[:digit:]]|grep "$team1 | vs | $team2 | match won by | $team1"|grep -v l$|grep -v r$|cut -d'|' -f11|sort|uniq -c|sort -t' ' -nr -k1|tee -a comments_n_notable_$team1$team2

                        echo -e "\n********************efforts in a losing cause******************\n"

			cat matches_won_$team1$team2.dat|grep -i ^[[:digit:]]|grep "$team1 | vs | $team2 | match won by | $team2"|grep l$|cut -d'|' -f11|sort|uniq -c|sort -t' ' -nr -k1|tee -a comments_n_notable_$team1$team2

			echo -e "\n ************************ Few notable players for $team2_name *********************** \n"|tee -a comments_n_notable_$team1$team2                  

                         cat matches_won_$team1$team2.dat|grep -i ^[[:digit:]]|grep "$team1 | vs | $team2 | match won by | $team2"|grep -v l$|grep -v r$|cut -d'|' -f11|sort|uniq -c|sort -t' ' -nr -k1|tee -a comments_n_notable_$team1$team2
			echo -e "\n********************efforts in a losing cause******************\n"                                             

                        cat matches_won_$team1$team2.dat|grep -i ^[[:digit:]]|grep "$team1 | vs | $team2 | match won by | $team1"|grep l$|cut -d'|' -f11|sort|uniq -c|sort -t' ' -nr -k1|tee -a comments_n_notable_$team1$team2
			

			echo -e "\n ************************ Few notable players in tie matches ************************"|tee -a comments_n_notable_$team1$team2
			 cat matches_won_$team1$team2.dat|grep -i ^[[:digit:]]|grep "match tie | 0000 |"|cut -d'|' -f11|sort|uniq -c|sort -t' ' -nr -k1|tee -a comments_n_notable_$team1$team2
			echo -e "\n ************************ Few retired Mom's ************************"|tee -a comments_n_notable_$team1$team2
			cat matches_won_$team1$team2.dat|grep -i ^[[:digit:]]|grep "$team1 | vs | $team2 |"|grep r$|cut -d'|' -f11|sort|uniq -c|sort -t' ' -nr -k1|tee -a comments_n_notable_$team1$team2

#http://hitwicket.com/discussionForum/74672/Head-to-Head--Comments-MoMs-Margins-and-Pitches-MVPs--All-Inclusive
#>> https://drive.google.com/open?id=1lyCkhwvKblxC6lOt6nvtEBjfHQbbpX53ZlD0g7CYmG8