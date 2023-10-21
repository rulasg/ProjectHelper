

#gh issue list --repo rulasg/testPublicRepo --json number,title,state,url
$TestData_Issue_List=@"
[
    {
        "number": 3,
        "state": "OPEN",
        "title": "issue number 3 of a test repo",
        "url": "https://github.com/rulasg/testPublicRepo/issues/3"
    },
    {
        "number": 2,
        "state": "OPEN",
        "title": "issue number 1 of a test repo",
        "url": "https://github.com/rulasg/testPublicRepo/issues/2"
    },
    {
        "number": 1,
        "state": "OPEN",
        "title": "issue number 2 of a test repo",
        "url": "https://github.com/rulasg/testPublicRepo/issues/1"
    }
]
"@

#gh project list --owner rulasg --format json 
$TestData_Project_List = @"
{
    "projects": [
        {
            "number": 11,
            "url": "https://github.com/users/rulasg/projects/11",
            "shortDescription": "Testing projects",
            "public": true,
            "closed": false,
            "title": "PublicProject",
            "id": "PVT_kwHOAGkMOM4AUB10",
            "readme": "This is the readme of the project",
            "items": {
                "totalCount": 2
            },
            "fields": {
                "totalCount": 9
            },
            "owner": {
                "type": "User",
                "login": "rulasg"
            }
        }
        ],
        "totalCount": 1
    }
"@
    
    
    #gh project field-list 11 --owner rulasg --format json
$TestData_Project_Field_List = @"
    {
        "fields": [
            {
                "id": "PVTF_lAHOAGkMOM4AUB10zgMy4G4",
                "name": "Title",
                "type": "ProjectV2Field"
            },
            {
                "id": "PVTF_lAHOAGkMOM4AUB10zgMy4G8",
                "name": "Assignees",
                "type": "ProjectV2Field"
            },
            {
                "id": "PVTSSF_lAHOAGkMOM4AUB10zgMy4HA",
                "name": "Status",
                "type": "ProjectV2SingleSelectField",
                "options": [
                    {
                        "id": "f75ad846",
                        "name": "Todo"
                    },
                    {
                        "id": "47fc9ee4",
                        "name": "In Progress"
                    },
                    {
                        "id": "98236657",
                        "name": "Done"
                    }
                    ]
                },
                {
                    "id": "PVTF_lAHOAGkMOM4AUB10zgMy4HE",
                    "name": "Labels",
                    "type": "ProjectV2Field"
                },
                {
                    "id": "PVTF_lAHOAGkMOM4AUB10zgMy4HI",
                    "name": "Linked pull requests",
                    "type": "ProjectV2Field"
                },
                {
                    "id": "PVTF_lAHOAGkMOM4AUB10zgMy4HQ",
                    "name": "Reviewers",
                    "type": "ProjectV2Field"
                },
                {
                    "id": "PVTF_lAHOAGkMOM4AUB10zgMy4HU",
                    "name": "Repository",
                    "type": "ProjectV2Field"
                },
                {
                    "id": "PVTF_lAHOAGkMOM4AUB10zgMy4HY",
                    "name": "Milestone",
                    "type": "ProjectV2Field"
                },
                {
                    "id": "PVTF_lAHOAGkMOM4AUB10zgM0BvM",
                    "name": "comment",
                    "type": "ProjectV2Field"
                }
                ],
                "totalCount": 9
            }
"@