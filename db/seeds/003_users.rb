User.create(
    id: 1,
    email: 'admin@hyrdd.com',
    password: 'test1234',
    password_confirmation: 'test1234',
    confirmed_at: 'Mon, 24 Jun 2019 10:42:14 UTC +00:00',
    confirmation_sent_at: 'Mon, 24 Jun 2019 10:42:14 UTC +00:00',
    birthday: 'Sat, 24 Jun 1989',
    active: true,
    deleted: false,
    first_name: "Admin",
    last_name: "Hyrdd",
    role_id: Role.find_by_name('Super Admin').try(:id)
)
