module HelloAptos::Message{

    use std::string;
    use std::error;
    use std::debug;
    use aptos_std::event;
    use std::signer;
    struct  Message has key{
        msg:string::String,
        message_change_events: event::EventHandle<MessageEvent>,
    }
    struct MessageEvent has drop, store {
        from_message: string::String,
        to_message: string::String,
    }

    const ENO_MESSAGE: u64 = 0;

    public entry fun  say_message(account:&signer, message_bytes: vector<u8>) acquires Message {
        let message = string::utf8(message_bytes);
        let account_addr = signer::address_of(account);
        if (!exists<Message>(account_addr)) {
            debug::print(&account_addr);
            move_to(account, Message {
               msg:message,
               message_change_events: event::new_event_handle<MessageEvent>(account),
            });
        } else {
            // debug::print(message);
            let old_message = borrow_global_mut<Message>(account_addr);
            let from_message = *&old_message.msg;
            event::emit_event(&mut old_message.message_change_events, MessageEvent {
                from_message,
                to_message: copy message,
            });
            old_message.msg = message;
        }

    }
    public fun get_message(addr: address): string::String acquires Message {
        assert!(exists<Message>(addr), error::not_found(ENO_MESSAGE));
        *&borrow_global<Message>(addr).msg
    }

    #[test(account = @0x1)]
    public entry fun sender_can_set_message(account: signer) acquires Message {
        let addr = signer::address_of(&account);
        say_message(&account,  b"Hello, Aptos");

        assert!(
          get_message(addr) == string::utf8(b"Hello, Aptos"),
          ENO_MESSAGE
        );
    }
}