{ id,body,title,updatedAt,createdAt,number,url,state,
  repository{ name, owner{ login }}
  comments(last: 10){
     totalCount,
     nodes{createdAt,updatedAt,url,body,fullDatabaseId,author{login}}
  },
  subIssues(first: 100){
    totalCount,
    nodes {{issuemini}}
  }
}