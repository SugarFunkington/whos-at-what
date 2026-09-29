ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "service_role";

CREATE TABLE "public"."families" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "name"       text                     NOT NULL,
  "timezone"   text                     NOT NULL DEFAULT 'Europe/Dublin'::text,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "families_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."families"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."members" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "family_id"    uuid                     NOT NULL,
  "display_name" text                     NOT NULL,
  "colour"       text,
  "user_id"      uuid,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "members_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."members"
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."members"
  ADD CONSTRAINT "members_family_id_fkey" FOREIGN KEY (family_id) REFERENCES public.families(id) ON DELETE CASCADE;

ALTER TABLE "public"."members"
  ADD CONSTRAINT "members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

REVOKE ALL ON TABLE "public"."families" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."families" TO "anon";

REVOKE ALL ON TABLE "public"."families" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."families" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."families" TO "postgres";

REVOKE ALL ON TABLE "public"."families" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."families" TO "service_role";

REVOKE ALL ON TABLE "public"."members" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."members" TO "anon";

REVOKE ALL ON TABLE "public"."members" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."members" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."members" TO "postgres";

REVOKE ALL ON TABLE "public"."members" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."members" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "service_role";

