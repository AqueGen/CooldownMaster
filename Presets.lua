local _, ns = ...

---------------------------------------------------------------------------
-- Preset Profiles (read-only, ship with addon)
---------------------------------------------------------------------------

ns.presets = {}

-- Display order for preset list
ns.presetOrder = { "preset:luxthos" }

---------------------------------------------------------------------------
-- Luxthos CDM Layouts
-- Source: https://www.luxthos.com/cooldown-manager-profiles-world-of-warcraft-midnight/
---------------------------------------------------------------------------

ns.presets["preset:luxthos"] = {
    name = "Luxthos",
    description = "Cooldown Manager layouts by Luxthos for all classes.",
    author = "Luxthos",
    url = "https://www.luxthos.com/",
    layouts = {
        -----------------------------------------------------------------
        -- DEATH KNIGHT
        -----------------------------------------------------------------
        DEATHKNIGHT = {
            {
                name = "Luxthos - Blood",
                spec = "Blood",
                data = "1|VY67SgNBFIZnxsTCGO0G/2lmZdKJb2AatbMQ0oSUC4oJiNusilaGBISApWC7SAJ5jLBVgsRLfIRYZHM13sBKziSNzffxn8M5/OXYVbCWDuKluy20qpAT5BaQi0GO0ZxA9iCHMGnICPoJ+hEmAZOEbismdnLQrzDL0C+QA5hVmBWEt+huQHegnxXj7gimqhgvnMI0yGcw+4qJRJ3COeGCPrURZihc0k2kGO9XCFmkpGJi6YHGA5gaeUh4J3wSvgjfhB/Cr2K8O1WMv10rxqMbAkW3T/ggTBUTSe9elP+PR3bnFKE76xVbyvZASsI0EGZsc97P2kK2i0jUa5C9YknwRcho7uHc45lNeubmxDqI+7uHrp939k4KR3nf2XS2jz3v4A8=",
            },
            {
                name = "Luxthos - Frost",
                spec = "Frost",
                data = "1|NY/PSgJRGMW/O9hE9QB1Li0mWtcmoVZBGG0MUnuCFpXyTQk6YLTKjJZRUGpB5hDRUyQtonqCdm3Fv5AVUVkQ34xtfudyuZz7O3uBHXdk1jVzxTnYJvgTG9PgGrgNux9cBzfATXAL3AF/gbvgFyQ7SL6Cv8HveJwB/4J/UA2B3zSp0zLuu5pUZBm2ATugSSXKsPskSwJXcCE4h02aVD4oqGhS0ZgmdXKtSS3VpGJL7gY0qeKt4EiTKoxqUrFBwZQmtX8o74bkdKNJHd9JwaK8Cwu2BU/SkpECkSjKb5FJTepsTfCMhw9NqpQSpDUZ48OXxu7/BiuLamjswBf1LDzHaMZfVhj1l3kG+aBf5bl7KzzjfOUKXM/mDGWCG71s9rLVy7aXrunMr644cSu8mViPO9aEtZBKpp0/",
            },
            {
                name = "Luxthos - Unholy",
                spec = "Unholy",
                data = "1|NZE/S8NQFMXvjaEKWhXR2vNAjG4OfgaXIgU3Qerg0kHaam4yWAU3a13F2tY/oCJF/AbioF2KSz+Bg4NbC4ogjqJUvUldfve8l5z3zkn27J1afK5mF08TkDhkHNIP99sQZ2KQFJp1uB0IGeLRDMSC9EFsyAC8N8ggpAe+D/8GEoX0GuK1V8gwZAgSUU/OEJeeDfFByxAfrqBVgoxAYoasmS3dmjDEiy+QMTW/6+JW1cefu8qGuLKhKqnqTk9cN8ST86o8hWuIow11fOlSFBVDXG4b4ty9om7Imn7UB1XFkeJYcWKI058a4kzxpDYolhWXeq++fP5giC9+rrgQNHJ2w+8wtR+GLreDOmHabp3/tEHQahIy0m0Slo42ruF2CkWLIxDqzlQ4m/VgBn9AFdfszcRqOp91FrxcJpt3Zp0lL+u7278=",
            },
        },
        -----------------------------------------------------------------
        -- DEMON HUNTER
        -----------------------------------------------------------------
        DEMONHUNTER = {
            {
                name = "Luxthos - Devourer",
                spec = "Havoc",
                data = "1|Pc+9SsNgGMXx502Km7Vj84KQuucqzOBNtAghYxKNiVFcDCmkHXQrSLcEr6J+QO5CwRuwtl28gfJ/hy4/zjnwDM+099gMHxq7evGcTrSoywISqJ1OOZ2tRZ21Wiz/hzGDG7iGHGZwBXNIuViSIoih0aKCNfzBBraw06KeVvAG7/ABn/AF3/CvRT0fQx9OYADnMIYJ3MG9FrU4BWrw20ppvhqVpr6al8rKUkdmPqTikGqTGrvwwyiJ3Ys8zsLU9Vw/vE3yNEz3",
            },
            {
                name = "Luxthos - Havoc",
                spec = "Havoc",
                data = "1|Lc09S8NwEMfxu7T4AoSCv5viKGhfhUNdXLMatEhDH0CiUF2McRJfgEvuEgTrlFkHXTpXV/sehC4iPlHlX7N8vndwcOf102JlmKRXTegD9BFlAJ3AOrALWAR9ghpsBOsim0NryH6hBPWgTWgd5TKyH9iJEH9tOwrYPfIX5FMUDSEOYyHe33GEbh06joX4Y89NqRDPa0L8uQ67E+LXSIhna0L8FjjGQvy+5bh0PLvTW8f3NSUoA+8MRQP5dDVZPLuBWpJ6vASd/Nc6VaOq3aqjRZN4s90b9P3WYT9uH/gbfis8Guz+AQ==",
            },
            {
                name = "Luxthos - Vengeance",
                spec = "Vengeance",
                data = "1|LZC9TgJBFIXvjujqG3CmWhurM6GxtrJQbJxC8CdAVrIqBWs0GgyVLAivYGsgoi/gA1hb+hzGisTERDOz29zvzrm5557MqHT/VO5ni+HjJuwF7Bh8hp2CY9gO2AQbsDOwDbbAEUwVfNAS/E5d2QeHYAaegIfgKXgA1sBjsA4egbEWVapoUUsbWpQ6A+ewe0781qJk103etajgR4uqbqH3ARNqCeI6zBp6E/BFS/DXd1IL5lOLWh7ArGpRYdc9vlz35pavZpKBYx9LZeDcO0ZZHnl94ldyv7juE8CEuVWp8go2BkMVrIDNgq2C7YKjnLZTcObpz7ku8J/itWxxV95OupdptHOb3iTXkYlqSXqexGk7+Qc=",
            },
        },
        -----------------------------------------------------------------
        -- DRUID
        -----------------------------------------------------------------
        DRUID = {
            {
                name = "Luxthos - Balance",
                spec = "Balance",
                data = "1|NdG5SwNREAbwN08RLEynzDxUVlAro/+AWmRtFLEIGrSMOUCIiQbTG5MueBQWki5sYzCtBGw3jRek9oCIFimj4oGVfLuk+X0zy7DD7BZ79yucyRfOVo2ijYBRtP7HCU6iq3CNm+yywxEuS7vO70KaP4SOhY6E9oQOZWmeX4SqQizUI+QaRakLoYbUT42ipyrHOG4UPV4ZRa0SL/OKkC16QHSAc1gyZBRtz4I5tIOoIiANMmAH7Ipew0ADG66NoocWqjtwD27BDUa9uWEwAkbBhFG0+Qre0E6CKRAE02AGjOML/Irdb5QOd/C2rNglPPwxip4XUX2DT/AloROsrUnoUuykUNDRBzjSKvr3dq8fK+JaHe50rzjnSL6gqY/Lfjh+1Pxw/Wh6Ie26l94v8ap8ZiGb24pbQSsUTUXTscQ/",
            },
            {
                name = "Luxthos - Feral",
                spec = "Feral",
                data = "1|RZE7SANBFEVnlpkNpLGRxDvVxj8EGyubdFGwFZVYBhVRE9CAoCKiieAn4A9NrIS4aiVa2vgprUWw0DQSQY0WVgE7c9eAzXl3uG/uvMesqKVCw1S6kjnoN0IGdo2QsXuqPagHI2SpCzoC7YMGdJjGjhEy6afaN0LGT6HmoFahFqCyRsjJc6gNqDWodSxaUPNQBRxOo/wKNQvlGiETIahjXJaMkMUhI+TzRDXopRM6C+1Cf8POGyHHJOwcA994qKc64+VWooloJlroCroXRsinbap3okx8suWO6oOqnWNfE1fEDXFLwzHC6uut7jtcZPMXuusQHaDThugg23i/+EPF4ACDY9wg2MguIhgjNoktgqMkjwgX+hG2H3bEtdJ/Ozrp/8VDGe912DnY+RNo33LGkjY0ajVcqxGvep/iqXQlGU3NjI84HU7PaCqe+AU=",
            },
            {
                name = "Luxthos - Guardian",
                spec = "Guardian",
                data = "1|NdE9SwNBEAbg3U0wm7s0AYu8g8UJomksU2hjIx7Y+hXxgwukiYJoINiJuWiTxN5GJIWof0IstLK3scinySXnT7DQuUua5x2YvR127ip62UidNSKV23Vk35F9IyHjCtojIWM+dIuEVL8waqhmYNQRT5JQax8kpHPEHJNQqT7jMUNmRELqJIwFGMvQHeg2dB/nc9Bd6B4u+MMYH4oNoZucHnQUekRCbSzxDT8wbqB9WCswBjxmk1suEg4SdzAdmDYJZU9za4vZYbLMLrPH7DMHzCEJWXhhXknIL+IRTabFtJkO02V6zDczYHwSCmkSij5JqJlH5omEmucj6Xu+fvtBuMG6gtVId/IC5QZdGAOrHKxk9hqmjYQTPsbkxzxDt8oVJaegvTDjyTCN2jjrYVYzQQb/Y1LF/HH1PzeoGpHT1WKpkLcWLbuUK+YLuZM/",
            },
            {
                name = "Luxthos - Restoration",
                spec = "Restoration",
                data = "1|Rc7PK8NhHAfw5/u0nNy398Nhz/NYubigUSOEIUwcnG1taq2strnvh5Cjk+taDvIHuDhxQCmGEQr7clb+gvGe1S6v99PT59eWJ1/2Zcqe0sE07B5MHsYLE4JRMIDxwVaVcKJ35JxckgvyQF7JC3kiz+Se3JJ38kiuySepEZd8/FHf5usNehx6DHoOehY6DD2DRgV6FHoejW/oCehFJeRyF3QEJ2ElZH8nWSL7pAYbga0r4ayvoveGU7/IFZfsKCEHusmREnLwTAkZTCghh4JKyOFJ2BH0uPg5RSClhBNzYddYcsyVcSXkglMRBdiqv9g+We+2S9j6PyOQavY6MfcQxlsoSacDxsd0YNBK1foPNbPsyU5lNpNxf59/JZHNpTPRXDK98Qs=",
            },
        },
        -----------------------------------------------------------------
        -- EVOKER
        -----------------------------------------------------------------
        EVOKER = {
            {
                name = "Luxthos - Augmentation",
                spec = "Augmentation",
                data = "1|NY69TgJBFIVnFnNeQc9UGGsTGgsrQ+ETYK8QVyVGlhhAjY0btPEJ0ETNxsbOl7Ax9IA/uwYVFiRqY6jNXYbm++beO3PPnM6cBHNnQareWGK4TgyIHtEnYqJNtIghMSI67C4Qz8QHERFvRJf4NcpZOyZejXJWHoiQ+JTWPfFilM7HggHxbpT2GoIL4ofho1FO9ssovbEszWvim3gySu/UBAdG6cLYKF3OyfhPTrNyuyjlpaAp5ZZgU+DKs0PBkUyvBDeMMrfaT/7h+Iwy8+fT2MkOiZ3uKucmH0hyksTC+I5o+XVHg2hbd6x71n3r2HpoPUocpKqrNW/X3U8vprPV7T23VMlXil7pHw==",
            },
            {
                name = "Luxthos - Devastation",
                spec = "Devastation",
                data = "1|TdA9S4JRGAbg84g8QXvRfSZrzqmGykpIW9r6A4mDRQQpJUZbb2+8Y2Q1tAaGfSwODUoKQuVXFtkPkJf6Ea1xl0PLdZ8PznPOc46CB5djruNexOHtw1uCVqE1aBlagdatkcyCNdIpwitxMgptMueh79AXaBf6hqFh9L+hbe7MkjlrAtE8tAPtoX8PbaG/Cv+ZezMkYo18fkEfoU843oM/AV+skY2iNbK2Yo0kRsg6/BiXr8ktuePxE5Inp+QM2oBf4PDcGmn0rJEmr2g9kKo10l4kUfYyRaYJq3ZuCEt3J0mYJMiHNfIaLIj7vy3JRAIu3+0XoI3Q4d+neKVxB37sClp23IAotDLI6iBrg6z/ppNdzqW3UjuhcCieyiV3s8nsZnr7Bw==",
            },
            {
                name = "Luxthos - Preservation",
                spec = "Preservation",
                data = "1|NdC/T8JQEAfwe71GGTEhxu9NsDngBoPGiMS4OahxEhEwloBogaLM8mMwDs4mDIQ4sLBp4l9Cu7E6sTiwkKh5bV2+n0sud+/y+ubjaKPfXfRed8HXYAtcAZfARUTSiKTATbgz8AjuQEipGLgAToLLQurCETIyv0LG/g68BPgZfAe2wQ2sboJr4FuY6/DG4BvMPzB/B7fADngppPJJIWV7MI+E1Nq3kCpeCalKDssX3c4JGdkMlttC6vxHSOU+9aMx3fvS1YGen+iY6nBhVoVUY08vyeu4FFL1Mx2niA61J2+qA29sdBAdJp7+54NN02Dedv0l/hFGNjMBJzs9Q62AC6HF0FJoObQZOgqMpELTge4gdObrf6dfdRcPh+16zXLiW/Fjx2pZTrt0X63bfw==",
            },
        },
        -----------------------------------------------------------------
        -- HUNTER
        -----------------------------------------------------------------
        HUNTER = {
            {
                name = "Luxthos - Beast Mastery",
                spec = "Beast Mastery",
                data = "1|Nc47LwRhGAXg95uI+AnOm7x8ik00Ej9AQjaIwrrFpWQwBYViZ8jMZ7BjtyCISqIiy+4f0GiIH+JaqF12aom8Es1zipOTnFpbpd7ZnVXPB5DeILlCcsvkFS+ZvP57OAsZh8xDJtCKIQvIP5B/Ig0hM5ASZA5dBJmEzCL/YjLDgocLJnM4BJmCTMM1UGih8I3CX70G19Q8ZTIjP0xmtJfJrMfKtuKUVNlRdpU9pcJk4kVlSVlWVpRV5Z3JHDwqT8qz8qK8Km/6aJDJHN0xmeMzJnPSoTP/2svgGnb//3VPBtesw9ms6pn2bGtscyMKyrbPFgM/jGzJD6OgnPwC",
            },
            {
                name = "Luxthos - Marksmanship",
                spec = "Marksmanship",
                data = "1|Nc+7SgNhEAXg+YPo7sJuJcTzg7B2EvENLEQUbARfIcVqvAVNDAhuwL14zYqFt7RJ8FoatDQIFuozBKx8goVgKSdg851hppiZeGCvMeKGvag+DeMJRhtmFkYXSQ5mA/YZzBYK77DfkH4g/YSVhdmEXcXoK6wh2D7SLy1qto2OD8uAZcJe16LmduEMI/HgTHH8TF7Y90lVi1o9JEckICGJtKidC1Yx2ScH7HlkiZyTSziLzGVyBUeY16ROfrSo4xtyS+7IPXkgj1rUyZYWVUu0qGRCizrlMb8zWjLj361M0H/ADdDxx+L+Rf/r4EgTRjeIMmoQSa6fYa8yXylueyV30l3Il9bKG/liubCy+Qc=",
            },
            {
                name = "Luxthos - Survival",
                spec = "Survival",
                data = "1|PdC7SgNREAbgcxLxGfwPDLspbJR9AiFGozGpJYVCCosUuhIwmCWFoGusNomXbtslWHkBsfOWRLBTX0Fs1FI3YC3/FjYfU8z5z8wcjO1FE5ko3QrzkBWjUrkdyCqkYpSuhcRD7ECKkBziMqQEd4BRGe4QsgCZhSxBvuE+GqU3AljXkDlIAe4nRrtG6cUpSBYyD8mj/wTrxyjd/DJKd57JC3nF5Axbp4ljlC5ckjfyztwO6ZJDckSOyQnTbsgtuSP3ZECGhIM1P4zSwRk5JxeEfwRXRun2L4eoGqW7JV7ggS/6jG/Dik+Vn5xF+8mGKT9ZwPYh2cw+rDjp60Eqfiulx5OL/VdhUkXprWKjtl2t24693Kh7697a5h8=",
            },
        },
        -----------------------------------------------------------------
        -- MAGE
        -----------------------------------------------------------------
        MAGE = {
            {
                name = "Luxthos - Arcane",
                spec = "Arcane",
                data = "1|Lc49S0IBFMbxc0TqC8Sh5zhoH8AGe0NvSC9zQnMh2FUCocDG3i9eIuwLRFsNTU0VRDnY1NBy79ySClGtbV2XOury+58znePHjy/HV736uYNGhMYvzpJAD4igPtAGOgiqkGXIDLqnkCyCN4gDmUe3iJAgC5AlyBRkDpKDTEMykDxkFuoq8XsciZoSbwRKnH1SYvfHpqYS58aMCyV2kkqcH1Xikxa0DH1BWLDtWYlvH5T4btfYM/aNA+PQODJulPg+bUwaa8b6/53HT+PL+Fbi14+rmIdEbcLvP4KwYKe0fA20vXqMR4DOsNGwvUHVHzSo9uttrZQ2K6l0anHHLW1X/gA=",
            },
            {
                name = "Luxthos - Fire",
                spec = "Fire",
                data = "1|Hc69SgNREAXgexexSOHfqPeeSbM2dj6BP+CqwR8WMW+gEEw2gugTmE2wuS8gVro+gqIWoiik0CpNOhvFZ0gtZ5vvMJwZmN7Yxa2v56Pu1QpCG+EE7kZNlCzCFQgZ3BDNKqQO2cTvN2Qbg0/ILmQPTcXgC7IPOYAkkBpkB7IBWYekkC019rJPXuE5LN+TB/JInsizGrt6rcYe9YFUjV37UWOzU3LG43fyoca+TJBJMkWmyQwRMkvmyDxxxBPAJ0wlVTX27Q+hBV+5i/LyRSCNOwjZQg++UlZJuVXAFZ1uZMfhhmXmo3Z6eNyIl+Ja67zxDw==",
            },
            {
                name = "Luxthos - Frost",
                spec = "Frost",
                data = "1|RdC9SgNREAXgezdBSHXvDVt4BoW1shLEP5CgSWUnCj6BiFwQUVCxScBdV2y2FmwjqdTCWlejJlEs9wVsElBM/IM8gEwUbL7DFMY5iDtl/uXyqnwuICoRcKZPkLUhJmEm4EqQe1BFaF82DzsLLJV6A+YNPQ3kgGoLsw4zATsDJJBmEVkT6A70F8wY9DvMAvQbehPmCkScmMUdoWELJySkLkX5pV5Y9pMh4Rc2yUhD2tMnYR8fuKNFo8JCRlfMldMzFwzN0yVuWXumHuGW2JuiRvMA/NIQtaGScj6BQnZOGPOSTg5tyIDqK4T9E70Qv5C1ISbGdr/v6MCVQxCR/ZBlf7S/02b72U5tT6/bFe9EW9ua3N75wc=",
            },
        },
        -----------------------------------------------------------------
        -- MONK
        -----------------------------------------------------------------
        MONK = {
            {
                name = "Luxthos - Brewmaster",
                spec = "Brewmaster",
                data = "1|LdDNSkJBGAbgOaOld1DvgHikYL6KCLqE9t5BEEFCZSpYTNsORtAu3NS2Vi3atOgmin6gMjP6HdcRlJ78KeOb3Dzv+83qZTajG/vDmaC0l4ZZgcnC5GDy0L/QPSW85DtMGaYA6oAEKAKSsNM42YXuQHehG7B30E3YGnQLdhZ2C7YCHUJ/Q//AVqHbsDHYOKiBsQQoroTnp0CfoBjoSwlv7gU0AGpi/AMTU6AuKOTnMyW8xR1u58wFc8lcoR4FtbleMzfMLVNl7kEtzhrzwDwyT8wz88q8MVYJmVhilpWQyVMlpD/ELDDHSsiRIyZUQo5WDmTg5qa23Ui3mUKeTS23vI169BC6F5SkNwgS/ZScHijSvzv/aQr9LLt0H+5aUEwX8lnfn/Rnipn13PzqWqb4Bw==",
            },
            {
                name = "Luxthos - Mistweaver",
                spec = "Mistweaver",
                data = "1|LY29TsJgGIXftxivoeeb6gX4tiR6AQ6O2N4CA4qYaPyJrhYwcVCRAMY4GDTGxEUq2FmLiW7GQVmMyMTkwMRsPtrleYZzck55av/KXC6OS+dzkCPICeRYEWdbGqHGo8aDRkejDanj7wJSgVQhp5AaHE8nAaSBrgnHhbME+w22D+lDfmHfwV6B/Qr7C3IG+VHE7QVFnL9UxJ2eIsP9UGR484o4GCL61llT4xqR7kQ9Rfyib54XMfpUxO8tpAuKuH+oiJ9YEYcpjO4hgxvy4bjGQbLK+SbShXgzGFo+pD5T1s3JTJiCDG4hFb9k8DSkmriWuBHb8WJ3zYmL483MxvqaNWtlVrd39nLZ3dzWPw==",
            },
            {
                name = "Luxthos - Windwalker",
                spec = "Windwalker",
                data = "1|LZC7SgNREIZnNuIDCBH/qdZmg4XgO3jpBCutI4pKQrygc1pjtLSShDVJs1gENOYBLLf0BdQigg9gq/GKzPE03zdn/hkYzunYcTa1lRUa6ZwQl28MfegFtAltQdvQVIgnE2gX2rH41jCAi6Af0E/oD/QXjuFKyPegX9A36Dv0GzqCm0F+LsTrK0I8HMElQrzdNwyE+OFIiB97Vt0ZhvacNywYloT4edVQsvTQevfIr4V44lKIiy/WWRTip9erqA6XxCf+PH/o9JkP/uf9VFjqQZv1RsTj0FZwGtwO7gR3vf0X+Cor7C/v1irxbLy2U9tw5Wpl8+AP",
            },
        },
        -----------------------------------------------------------------
        -- PALADIN
        -----------------------------------------------------------------
        PALADIN = {
            {
                name = "Luxthos - Holy",
                spec = "Holy",
                data = "1|LcsxTgJRFIXhdwlxBxbnVeMCpHMPNogSNjAJjYRgcqCh4zkgakJiMoJUEBhEIVFC2IU7sLCYgnaGDZiQS2i+v/rb2dbk1AXDHJgHr8ApeAMWwBFYBLfWiN9WHpWu0lEewEj7rDyB7+DcGvn7AZfgDPwHx+AHkg24AD+RXFgjqxAsIQmRlpDU9e0pL9ZIJVRelb4yUN6UoTXyFVsj3ztr5DdAGqOxjsSBY8+B0dk9Gmuk8QwsuCAjJ2Dx2NGx20Nd7dqv+uXbmnfuXd5Vm3s=",
            },
            {
                name = "Luxthos - Protection",
                spec = "Protection",
                data = "1|PdC7SgNBFAbg2UVs1Fb4p8rGUoX/FWzEG2TVFzB4IyIJmGyuXrK7gSQWip2VJhrwDdJY5jVskz5NavnXYPOd/zDDcM60Fpr91WgWv25htIygiqAGhgjqYGyNs1QEI7ANttTtgy9gAN6DVfABbIIVnayBT+AdeIvyClgD62ADLINdjL4RNKxxTo7BR1SmYEfdNsrr4LPiDiYexkPFXbEnDkRG+OJQHFnjXH2KN/EuBqIn+uLDGheX1rg2LbLWuN6GuBA90Re65/1Y46Yzwh+YMNnRjcBuMm1KH+G1/8bEeAh2tMDEQ2X6BYZh7DqLYDSv8by25rWd1OTN/1RMUjQr+dnr7Fkun9pM+TeF0vlpKVfI/wI=",
            },
            {
                name = "Luxthos - Retribution",
                spec = "Retribution",
                data = "1|RY89S4JxFMXv9YkWo7E4d7IP0FhDTUFTN+hleJ4aDRuMMAgtCJLMtgZpc5XKSsUKGgoJDQkks/e5IWntM8R9UlrO4V7O/39/Z69nJzeYc9LZcegt9B56J8RTc0I8sw1tQKvQGrQF/YD7DX2F24b7BW8Tngt9g77DW4A+w9uAtwhtQ1/gebj6FOJyRoi3WkJccqAVNJPQGyEO1oX4YkCI+0aEuH9UKDCZEOJLy67kTc5MikJchBBPp2w8NjkxORXiQtbkx541LVKw0X4uj9nuweQRem23JozhQIjPI7Z+OqRdv6PfNpD+z/u3hvZ9zj8mo+OS04X1scsZNJPdbsE6tHIErabSAe6F1jre6HjL95yTmA2vhiPRWGg4NL8cX48uJeLRtdgv",
            },
        },
        -----------------------------------------------------------------
        -- PRIEST
        -----------------------------------------------------------------
        PRIEST = {
            {
                name = "Luxthos - Discipline",
                spec = "Discipline",
                data = "1|LdC7TgJBGAXg2YkxEyDZBRvPVCuFooJXErHQxERjYuU7GIpNjBCRxsoVxPu1EFsLE2vlIvgAVLzB0irGzhdQz0Lznclk/sycKQ4cPA7Pu4WHNag61BtC+1Dv8JrwftGJItyCakI1oKrw8lAVqJoWcnlBC7nR1cJIzGphxF2YHwgNwewiMorQOswvmJ+IlGB+89AcgnUtjEwZgQysGKwAp861kIuWFjLVhpfkTpEckRI5JifklJxpIe0fri7IJbki1+SG3JI7ck/KvHyMxMg4mSCTJE4SZIpMkxktjOywFnLphbySihZyRT6JQ785VNVwEazLAqyYXwNWwHb9vxgp9p8oU22/HLzkM1TFLUhj8H+wn7V+NvrZ7GW41Usv38tO1E83t7nrpHN7dsJedXJbTnbb2Un/AQ==",
            },
            {
                name = "Luxthos - Holy",
                spec = "Holy",
                data = "1|Xc8/S0JhFMfx81z0crz5OERgvwPFJSxFCUTK6J9BU9Bi0NIcDUERZA1teRXbmtvKtEGKhqaWgggaWnoBvYSWlqQxjvdOLZ8vD+cZzmnGTtujM0G/cbEEHoKXAyfBFuzBlsEMjoNdcAJeHl5ByKk8CJnepZCznkHxCcVnfV/BVmDnkLqBXYCdh11Eqgu7LGQyJaQJwx8YeUdtFekVIZOd0MGb8itkJvPKufIjZKayypbyrZ83lZbyKGRyY8q4UlU2FJ1ufwqZs5jypUu1lWulo3SFzO2xkLmbVV6FzP1Lh+qDo5zmv91KfhCe1wPH6w3HuGA3KkdNRPWiJqPasF4hrC0PGvT3q4e7O7Ujf9pfO9g7+QM=",
            },
            {
                name = "Luxthos - Shadow",
                spec = "Shadow",
                data = "1|LdA9S8JRFAbwc69ipRK09Vz444UKGmzrTUiipcwyLa1WBYVqSLCghoJEyxYnhxqKNFDbHBxq6AP4IRr7AC3NxmMuv+fC5dxzzym7bxqTCw1X6TEOq42o52tyhWAK1g3rg/Ug0If1wyrUQ0ZUZcaIapdhRzHlhTMPJww7DjuCS8COwVmCswhnGc4KnBDSNdakjKimF7OHyK0hW0WwZ0Sd5Hi1TjZIhGySKNki2yRGdkicJMgu2SNJsk8OyAP5MKJenti0Tb6MqNYEYbdWh3xzDBC+3I4b0avC0y25IxVyTz7JjxH1Nm1EdbiHriL8XzeGzLsRHT4leSM68mtER32vuoRgD9nqYHpbRLrWRKBfLGnlgVXD9AzT/5/10CAbrnyicJw7O7dzNnmUyeYv/gA=",
            },
        },
        -----------------------------------------------------------------
        -- ROGUE
        -----------------------------------------------------------------
        ROGUE = {
            {
                name = "Luxthos - Assassination",
                spec = "Assassination",
                data = "1|RdFLS1thEAbgGS/9BQq+4ya6szbgRi0Iba2uXQji1ggq8bo4VeaUQnuioRyhUBBCrIJpjBpw13rFha69/5C6a3YK8kbBzTPzzRnmm4+zVPftd1NbtJgfgn+Bf4VnUemCL8ADE83dwXOMtaSO1CN8C0/DV7DSwsIofNlEU/fwn/AfCDsQdiIehq+h8h9hD763Imxn6z94xkTHL010ZBqfxxH2m+h6I4vniI9NdG2UnLDcYKK7RbJJSiY6lWS2RbbJjokWOHvqPfmAcACld0x7SR/ivIn+es3DRxOd/Ev2THT1gVyRa3JDbk20eAqfMdFNM9Ey+8vsL+9zRjezA3JIjgi3Lt7xCRc8LpEs+cMPZxzVbKIbvLDATQpvShLBczWZp/ePTCcieKYl+7J9EnEe8fEWPIgWa/QVfOE55p5ipasaq/+omkXzg3MT82OJZKI3CFJBkJ5NfUrPzT4C",
            },
            {
                name = "Luxthos - Outlaw",
                spec = "Outlaw",
                data = "1|LdC7SgNBFAbgmSiiLxD9p4qFjbDTWHpNGVACYZNKIUHUIqIWidEUXjZ5gR1SCKYwmdw2W4mooCIEn8Ai4N1KsLFNChs5uzbfP8OcOXMpDh5VxiatXuEkCrkIuYS6ARmHNOFE0NKQCThlwfjlHDEDNQo1ATUFdS4YvzqDCqOmoUZg/0JFYX/CfoD9iNo37B+oFag01D7VVmB0oTQafciUYDxdgkwKxteX4Q6g+oz2NHSQjpknFgTjO6s0CqNK9TcZ2uSRJXaJPciYYLzj0iRH0FnpvGD8+kUw7rwSb8Q78UENZ5G/EIzfxan0kDigHjWiQTSJOtESjCe/4J4Kxm+HaZNJJGjNIdqC8fsnHbAgU2j0QxY90eiOF/1Ld1x6mQ42Ic3jQoAPQSb8rBt+trSfTuQ/y156f+6NrN5WbHsjuxYyQtFsZjOV+wM=",
            },
            {
                name = "Luxthos - Subtlety",
                spec = "Subtlety",
                data = "1|Lc+/S8NgEMbxt2+lo6I1aZ7XKHHqUDp30H+guIgujiIUIQiKtoO9xdiCZkgTnLRbwBSH7q4q+FunUhwyuNnBpbh0EuRMl8/3pjuuOXEUGoUw3ThfUiK1+YXTVbhDRG34eXgmvAG8Mup99EYgDWSApkHA2YcScnIfpBB9g3IgHTQHmoWrg7LoLIPmcfILMtFxlZDaD2gBrQ0EMbol0IwSKfuGuWXumHvmgXlknphn5gVBgFaBx1fmjXlXQk5llJDZC/gxVyCw+VRRCalfKyFzK8ynEtI4uBTHyYekSQfdkuXAzy82EdjJcvjxFep9pyFTGZCW1B0m9cxxy+MOkkbtpL3Rf8P03trudq1iFa312lZ1p1I9/AM=",
            },
        },
        -----------------------------------------------------------------
        -- SHAMAN
        -----------------------------------------------------------------
        SHAMAN = {
            {
                name = "Luxthos - Elemental",
                spec = "Elemental",
                data = "1|NdDJSkJhHAXwe69mg9WqwXNBMAgCwyb+H2mJEGQWNkGLFlogJimolPgAyb1FAw1Ui7bhuldogEuLeoZ6EZs4Ypvf+fgmDn/bfXDvS9Ssuy3IPGQOEoGEIbOQGUgcEoXETE13XMQNWYWsQd1CLKhjqBPICmQdsgh1CVmAJKBOIUtQ51AXUFdQ11A3UGeQZcgh5MjU9OkvpD6Q+oTYkKSpGcEG0jumpkdCPP0mP+TX1PSwbmp6/pErg7iw7We2IVtgekg76SCdvP2EtJf5TF643UW4F+4mPaSX9JF+MkAGiY/skX1SIe+sN0xGyCgZI+NkgkySKVPTq5t88cbVAwfHig4rOqzosKLDQg4LOSz0uls37P8B8JERbDT/CNgcUmtaySEL2QK2/Uh765BozTJ0DyTWyngza5WNfKaUKQdCgXgxV8qVq5niHw==",
            },
            {
                name = "Luxthos - Enhancement",
                spec = "Enhancement",
                data = "1|NdDJL0NRGAXwe0vEAgnSxLmrWll50jaRaNNHn0gsKFLsa0gq0hoiUTu0TfwJtuIvkKC0hqIlhrAwLkrMw7YLFjZy+mLz+869N3kv34kVzy7VtM9/RxcHoQWhjcE+A20S2gScWTiscFdA98GzBncH9Dzc9WhZg2tICen1wxuHqxJNP3C1Q2+AJ8/rLtJNetAyDe8jYwfpxFcVpw+GG/YcPBE0r0IPKSFTA3xIoXFcCVldzsMW2Sa7JE32yAHJwDnKmUWRlfOQHCkhR3pJHyx51PkY+/lyTE7IKTkjV+RaCZk8Z7phumC6JXckR+5JYYsn8kxeyCt5I+/kg3wqIY0NskmSvHtQQiaWeOQSBncyuJOxT7iOkVFCxsqYEkrInVYl5O66EjL9q4S8DCghr0rJihLyumrZEvv/mlmc+QdbnMXqIbbqicCeq10w20le/BdrdpI8Zz3O0WVoE3NRiyyBw2pOZ7Yw57+n/MFAKBC21dvawsFAeHA4NBye+gM=",
            },
            {
                name = "Luxthos - Restoration",
                spec = "Restoration",
                data = "1|LdC7S1xBGAXwmVXSCbvrgz1j1BUfUcg1vvFJqii2StA0wvUBsYgLuqe+97oRQU3wCXay2ARSJ2gCIpZqlf9EYpRYyVlv8zsfDMN8cz6Xh8XMRLGscDQLJkEPTIFpsAqsBKvBGjCD8N4Ze1F0xp4fgwBbEdyBbWAWbADrQYfgO/gSrANrwVdgC9iE4B+CewQPYCPYjuA/gkdnbMcZwgeEf8BmZ+zZb2ds51dnEt4NbisQ+eAMOO2MXVlAtK4LnuhAdK18I7pEt+hxxi7Na+oVfaJfDIhBnc5pGhIjYlS8FaeIrvT6ptgS2+KL2BG7Yk/siwNx6IzteifGxLgWTSFcdMb+OHfG/kyKlEiLv87Y09f6aafQ5r+GnbGX3eAHrL0/SRRKDeC2olRHtgA2PzfUuIFoHdEVomtwGpyJS/G/gamokLAvwHSclXFWxVkdZ02cmTi9UhbL8lMf/U/+ctbLTi6u5nMrfn4pt/wE",
            },
        },
        -----------------------------------------------------------------
        -- WARLOCK
        -----------------------------------------------------------------
        WARLOCK = {
            {
                name = "Luxthos - Affliction",
                spec = "Affliction",
                data = "1|RY4rS0RhEIZnDib/gPtOWg1vswhWwbSKP8CgRY4e2PXoomwwysdy2OolGCxiM/kTLBbxfkEtshsMgph0v+QiUzzlYZ6B4Zn20PZRZSH0w8EEOmsmmv06BuAzOjn4iphhdg58QVxBbIO34AN4Az4inoP34AV4ibgM3pkkw3uOXfAJMQWvwStf7JhoLBynrvs+LZrozwB8N9GvM/DNRBtqojMjjoprYqK1E9cpE/3YMNHPMUfNj7Ych2DXRL8nwd6xhvKHpPgvl9GiLI8GsAd2Q781v7SZN9PV6nh1OsvyetqqN9f/AA==",
            },
            {
                name = "Luxthos - Demonology",
                spec = "Demonology",
                data = "1|XZDBSgJRGIX/+Y3qjlgN1dC5q0lsmds2tbBU6gna5CItJLUGoo27ZkbIZcughbSIoIXSQjeBb1BkRD2Bz3CFNnFnFKHN+b5/c+7hNmauH9aOvOBuC80O5l7BLUmc95FIwuxJYquL+FASL95CZaFyUBk02xB1iA+IIsQA6gmig9gC5t+hdmEaEPeSeOlMRwVqDyINwfqq6saStpq2oo4T3d5HTIBH2CCkPpEawF6VZOx/wSlofuv4kWRUtnXsSOLlMuwX2G+SeIUkcboP/pVkHOjD6j2SF643/OkUvgk3gEfTd/8Ncjw02+sBnELU/gxueQEbszB7EePDiIlkRJUZMztmLmT4ZROzuhPL+6F5V4fHlzW3VHU2nezpuXvh1txy/Q8=",
            },
            {
                name = "Luxthos - Destruction",
                spec = "Destruction",
                data = "1|PZDNSkJBGIZnRjHsCnxnIQZtwzsohTbvslWrKJPCzLT868efjudo2R20PRBB0Z20iKDuop1wTps0Zs7Bzft88w588zDjpONn9vyE91gA3zD9wvQbvxmwATpgBRyCPXAA9uGGCDyEWS2kmoBt8BJsgVcIf8AuWAfPEbyC12AHvNFCrR6Y2EfwCTbBCy1UumiqQy3UyrqZSlqolLlI+eAZWDNlXgv596yFnM/AO/AenOK4C7payOqmFpKeCXvcMtOtCcfEyHQFLeRix8RCC5V8Nw9/mFiAY7CqhRLiSbpWz4qqh6VSPjaU89nS0I81rZZKF3Mj+w9rnt0ULX0BKyNPyRTYi9mPOYg5jOlEdMOIgRcxzFr6ic5uqVlrlE9zG7nto1a72Sm3Txr1fw==",
            },
        },
        -----------------------------------------------------------------
        -- WARRIOR
        -----------------------------------------------------------------
        WARRIOR = {
            {
                name = "Luxthos - Arms",
                spec = "Arms",
                data = "1|LdC/L0NxFAXwe0UsFoPE91w0LbNBxCC3A8mzWEXMpqZ+VZ/EhLy+vuAfEK02ogz8AV00pBgFISwS/gbbG0Vu+5bPuds5uVFv0OgP43LFc8NuRIgbS4jukS1CC0K88+0E2oQG0DY0RNQW4smiUTPq8K6hp9AT6DtuZ5HdgtZcCtEjtA6tQKvQN+iZEO8uIFuAfkA/4Q1a2TGiByEuDQnx3g9uYiHOOUMMG5QbNTLGmDFuwEgJ8fO5EL/MC/GrZ9eBcWgcCfHUgG38FeLpGWPVWDPW8bdvi+6sOG9cCvHFohB/PaHlGpkSWu7KSancw33QIMkwyWaS7W5G3ex8rHOF8ebyiu/nC356Ij3nb2z/Aw==",
            },
            {
                name = "Luxthos - Fury",
                spec = "Fury",
                data = "1|Lc49S0JxFAbw/5Gohr7A84fElqLINF8qKq042d7U4NQkLQUXHFrSq13L6GVwiaZC7MW1IQgvBNUWBG4NEfkFGvoC8WjL7+HAOTxnv694NeSWzzPQY+gJ9NQaqVfgDUMj0Bo0Co3BS8ELWiPTz+SFvKKdx2oFOgONQxfRakJXoGfw0tBZaAKahM5BF6yRvSdoGroE/WXBAfwOMsvwL6yRRNUaKV5aI7l5MkrGCC9zkyRMImScTFgj7w1yTZrkhtySO2sk/kC+0fphwz35tEaSA9ZI4Y1k2TpFcnzpkFTx+MU84uqgNfKxXg+U4He6H4ZctPMjpd5OIduARt1yQPqhsf+sMQVesDd7qW662xubjrO144TCobW8s/sH",
            },
            {
                name = "Luxthos - Protection",
                spec = "Protection",
                data = "1|Lc4/T8JAHMbxu5ZUURCi0ficFAqF0cnortOzKOri5KDGGBabNH0BavHPS9CxhoHFhc2wOxsnfAMSZxcTHcwPb/l8f5e73F03d5EVMze93wJXQB+sgDVwFsyBJTAEy6AHumAdbIAFo3RPYfAJGnAGnAIXMPwGl8E5cBpvH2AeLILz4CK4hEEfBNgEW0bp4038PmMYGqXP2kY5/hPGP0bpUU2oCL7s7Qn7RunXVKZDmbrCnXAt3Ai3Run1L4yNUU51TRYPwotReiMQdoRtoS2fd4zS73mZtLwlR0bVR+cKbIHNejq56f+9nu6D7mXqaA/0bAu2Jduybd22YRtOmrnJwVEcd6I4WA124yg5PUk60fkf",
            },
        },
    },
}
