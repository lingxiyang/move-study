#[test_only]
module HelloAptos::MessageTests {
    use std::signer;
    use std::unit_test;
    use std::vector;
    use std::string;

    use HelloAptos::Message;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(12))
    }

    #[test]
    public entry fun sender_can_set_message() {
        let account = get_account();
        let addr = signer::address_of(&account);
        Message::say_message(&account,  b"Hello, Aptos");

        assert!(
          Message::get_message(addr) == string::utf8(b"Hello, Aptos"),
          0
        );
    }
}