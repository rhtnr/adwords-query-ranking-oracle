adwords-query-ranking-oracle
============================

On-line advertising has been one of the most booming markets since the first on-line ads showed up on the web and now 
it is a market of hundreds of billions of dollars globally and it still has not lost the steam. Google got $32.2 billion 
in advertising revenue which is 97% of Google’s total revenue in Q3 2010 - Q2 2011. By far the most lucrative venue for 
on-line advertising has been search, and much of the effectiveness of search advertising comes from the “AdWords” model 
of matching search queries to advertisements. For this project, you need to use Java to access an Oracle database and 
accomplish an on-line ads auction system using various bidding algorithms. 1.1.1 Definition of the AdWords Problem 
We are going to consider on-line algorithms for solving the AdWords problem, which is defined as follows. 

Given: 

• A set of bids by advertisers for search queries; 
• A click-through rate for each advertiser-query pair; 
• A budget for each advertiser; 
• A limit on the number of ads to be displayed with each search query. 

Respond to each search query with a set of advertisers such that: 

• The size of the set is no larger than the limit on the number of ads per query. 
• Each advertiser has bid on the search query. 
• Each advertiser has enough budget left to pay for the ad if it is clicked upon. The data set consists of three database 

tables: (primary keys are underlined) 

Queries(qid:INTEGER, query:VARCHAR(100)) 

Advertisers(advertiserId:INTEGER, budget:FLOAT, ctc:FLOAT) 

Keywords(advertiserId:INTEGER, keyword:VARCHAR(100), bid:FLOAT)

A query is a sequence of tokens typed on the search engine, e.g., “the best restaurant in
Gainesville”. One token may appear multiple times in one query. The click-through rate (ctc)
is the number of times a click is made on the advertisement divided by the number of total
impressions (the times an advertisement was served). To make the output unique, we assume
the ctc is constant for each advertiser. Also we assume the first x of the 100 impressions
will be clicked and the rest 100−x impressions will not be clicked if the ctc is x%(x will be
an integer). The same simulation process repeats for the ads’ second 100 impressions, third
100 impressions and so on so forth. The Advertisers table stores the advertiserId and the
corresponding budget. The budget is in the unit of dollars. The advertisers can’t bid if the
balance is less than the advertiser’s bid. Each advertiser must provide a set of keywords that
best describe the ads to match the search query. One advertiser has one and only one ads.
The bid in the Keywords table is also in the unit of dollars.

Matching Bids and Search Queries

Each ads has a set of case insensitive keywords to match the query. Each keyword in the
keyword set is associated with the price the advertiser would pay if the ads is clicked. The
advertiser will bid the query with the sum of the price for each matched keywords. You
may need to tokenize the search query. For simplicity,the project assumes the delimiter to
tokenize the query is the empty space ‘ ’.
T ← matched tokens set(query,keywords) ; T contains no duplicate tokens

On-line Auction Algorithms to the AdWords Problem

One advertiser bid one query iff the bid > 0 else the advertiser will not go into the auction
process. Assuming that only K ads can be displayed for each query. It is also possible that
the K slots are not fulfilled if there are not enough advertiser to bid the query.

The Greedy Algorithm

For each query, the greedy algorithm picks advertisers who has the highest bid for it. The
Top-K advertisers who bid the query and have the highest bids will be shown.
1.3.2 The Balance Algorithm
There is a simple improvement to the greedy algorithm. This algorithm, called the Balance
Algorithm, assigns a query to the Top-K advertisers who bid on the query and have the
largest remaining budgets.

The Generalized Balance Algorithm

Suppose that a query q arrives, advertiser A i has bid x i for this query (note that x i could
be 0). Also, suppose that fraction f i of the budget of A i is currently unspent. Let Ψ i =
x i (1−e −f i ). Then assign q to the Top-K advertisers who bid the query and have the highest
Ψ i .


Add the Ads Quality into Ranking
The above auction algorithms don’t take the quality score into consideration which is a
metric to determine how relevant and useful your ad is to the user. The higher your quality
score is, the better. In this project, we define the quality score as the product of ctc and
cosine similarity between query and advertiser keywords: The attribute vectors A and B are

the term frequency vectors of the query and the advertiser keywords.
QualityScore = ctc ∗ cosine similarity

Finally, the
final rank is defined as follows:
The Greedy Algorithm Ad Rank = Bid × Quality Score
The Balance Algorithm Ad Rank = Balance × Quality Score
The Generalized Balance Algorithm Ad Rank = Ψ× Quality Score

Charging Advertisers for Clicks:

The advertiser will be charged iff the ads was clicked.
first-price auction when a user clicks on an advertiser’s ad, the advertiser is charged the
amount they bid. This policy is known as a first-price auction.
second-price auction In reality, search engines use a more complicated system known as
a second-price auction. An advertiser for a search will pay the bid of the next highest bid
advertiser who bid the query . If the advertiser’s bid itself is the smallest, it will pay the
price it bids in this case. It has been shown that second-price auctions are less susceptible
to being gamed by advertisers than first-price auctions and lead to higher revenues for the
search engine

main execution file- adwords.java
