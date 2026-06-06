{ id, url, title, number,
    owner{
        ... on User{login}
        ... on Organization{login}
    },
}