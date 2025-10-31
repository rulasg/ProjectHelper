{
    __typename,
    ... on ProjectV2ItemFieldDateValue{
        date,
        field{{field}}
    },
    ... on ProjectV2ItemFieldIterationValue{
        title,startDate,duration,
        field{{field}}
    },
    ... on ProjectV2ItemFieldLabelValue{
        labels(first: 10){
            nodes{name}
        },
        field{{field}}
    },
    ... on ProjectV2ItemFieldNumberValue{
        number,
        field{{field}}
    },
    ... on ProjectV2ItemFieldSingleSelectValue{
        name,
        field{{field}}
    },
    ... on ProjectV2ItemFieldTextValue{
        text,
        field{{field}}
    },
    ... on ProjectV2ItemFieldMilestoneValue{
        milestone{title,description,dueOn},
        field{{field}}
    },
    ... on ProjectV2ItemFieldPullRequestValue{
        pullRequests(first: 10){
            nodes{url}
        },
        field{{field}}
    },
    ... on ProjectV2ItemFieldRepositoryValue{
        repository{url},
        field{{field}}
    },
    ... on ProjectV2ItemFieldUserValue{
        users(first: 10){
            nodes{login}
        },
        field{{field}}
    },
    ... on ProjectV2ItemFieldReviewerValue{
        reviewers(first: 10){
            nodes{__typename,
                ... on Team{name},
                ... on User{login}
            }
        },
        field{{field}}
    }
}