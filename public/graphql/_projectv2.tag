{ id, url, title, number, readme, shortDescription,
    owner{
        ... on User{login}
        ... on Organization{login}
    },
}