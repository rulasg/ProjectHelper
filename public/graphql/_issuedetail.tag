{ id,body,title,updatedAt,createdAt,number,url,state, repository{ name, owner{ login }}
  parent{{issuemini}},
  comments(last: 10){
     totalCount,
     nodes{{comment}}
  },
  subIssues(first: 100){
    totalCount,
    nodes {{issuemini}}
  }
}