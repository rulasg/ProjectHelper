{
    __typename,
    ... on DraftIssue {id,body,title,updatedAt,createdAt},
    ... on PullRequest{id,body,title,updatedAt,createdAt,number,url,state,repository{name,owner{login}}
        comments(last: $lastComments){
            totalCount,
            nodes{createdAt,updatedAt,url,body,fullDatabaseId,author{login}}
        }
    },
    ... on Issue{id,body,title,updatedAt,createdAt,number,url,state,repository{name,owner{login}}
        comments(last: $lastComments){
            totalCount,
            nodes{createdAt,updatedAt,url,body,fullDatabaseId,author{login}}
        }
    }
}